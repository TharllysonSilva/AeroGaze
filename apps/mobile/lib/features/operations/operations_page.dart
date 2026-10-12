import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/design_system.dart';
import '../../core/database/field_database.dart';
import '../../core/sync/operations_api.dart';
import '../../core/sync/sync_runner.dart';
import '../auth/auth_widgets.dart';
import 'scenario_view.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({
    required this.session,
    required this.onSignOut,
    required this.onOpenDemo,
    super.key,
  });
  final ApiSession session;
  final Future<void> Function() onSignOut;
  final VoidCallback onOpenDemo;
  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage>
    with WidgetsBindingObserver {
  late final _api = OperationsApi(widget.session.baseUrl);
  late final _db = FieldDatabase();
  late final _sync = SyncRunner(_db, _api);
  final _notes = TextEditingController();
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _farms = [],
      _tasks = [],
      _alerts = [],
      _plots = [];
  int _tab = 0;
  String? _updatedAt;
  bool _cached = false;
  List<OutboxData> _queue = [];
  final Map<String, Map<String, dynamic>> _receipts = {};
  String? _farm, _error, _deviceId;
  bool _busy = false, _offlineTest = false;
  Timer? _timer;
  String get _scope => widget.session.scope(_farm!);
  String get _cacheKey =>
      'farms:${widget.session.baseUrl}:${widget.session.organizationId}:${widget.session.userId}';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _synchronize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _synchronize();
  }

  Future<void> _load() async {
    try {
      final cached = await _storage.read(key: _cacheKey);
      if (cached != null) {
        _farms = (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
        if (_farms.isNotEmpty) _farm = _farms.first['id'];
      }
      if (mounted) setState(() {});
      if (_farm != null && mounted) {
        await _restoreOperations();
        await _queueRefresh();
      }
      final farms = await _api.list('/v1/farms', widget.session);
      await _storage.write(key: _cacheKey, value: jsonEncode(farms));
      if (!mounted) return;
      setState(() {
        _farms = farms;
        _farm = farms.isEmpty ? null : farms.first['id'];
        _error = null;
      });
      if (_farm != null) {
        await _restoreOperations();
        await _db.resume(_scope);
        await _refresh();
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
      if (mounted && _farm != null) await _queueRefresh();
    }
  }

  Future<void> _queueRefresh() async {
    if (!mounted || _farm == null) return;
    final scope = _scope;
    final rows = await _db.rows(scope);
    if (mounted && _farm != null && _scope == scope) {
      setState(() => _queue = rows.reversed.toList());
    }
  }

  Future<void> _refresh() async {
    if (_farm == null) return;
    final farm = _farm;
    await _queueRefresh();
    if (_offlineTest) return;
    try {
      final values = await Future.wait([
        _api.list('/v1/tasks?farmId=$farm', widget.session),
        _api.list('/v1/alerts?farmId=$farm', widget.session),
        _api.list('/v1/farms/$farm/plots', widget.session),
      ]);
      final updatedAt = DateTime.now().toUtc().toIso8601String();
      if (!mounted || farm != _farm) {
        return;
      }
      if (mounted) {
        setState(() {
          _tasks = values[0];
          _alerts = values[1];
          _plots = values[2];
          _updatedAt = updatedAt;
          _cached = false;
          _error = null;
        });
      }
      await _storage.write(
        key: 'operations:${widget.session.scope(farm!)}',
        value: jsonEncode({
          'tasks': values[0],
          'alerts': values[1],
          'plots': values[2],
          'updatedAt': updatedAt,
        }),
      );
      final queue = List<OutboxData>.of(_queue);
      for (final row in queue.where((r) => r.status == 'synced').take(20)) {
        final receipt = await _api.request(
          'GET',
          '/v1/sync/events/${row.id}/receipt',
          token: widget.session.token,
        );
        if (mounted && farm == _farm) {
          setState(
            () => _receipts[row.id] = (receipt as Map).cast<String, dynamic>(),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = '$error';
          _cached = true;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_farm == null || _busy || widget.session.role == 'auditor') return;
    if (_notes.text.trim().isEmpty) {
      setState(() => _error = 'Descreva a inspeção antes de salvar.');
      return;
    }
    setState(() => _busy = true);
    try {
      await _db.save(_scope, _notes.text);
      _notes.clear();
      await _queueRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspeção salva no SQLite e enfileirada.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível salvar no aparelho. A descrição foi mantida.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _synchronize({bool manual = false}) async {
    if (!mounted || _busy || _farm == null || _offlineTest) return;
    setState(() => _busy = true);
    try {
      await _sync.run(widget.session, _farm!, manual: manual);
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _switchFarm(String? farm) async {
    if (_busy || farm == null) return;
    setState(() {
      _farm = farm;
      _queue = [];
      _tasks = [];
      _alerts = [];
      _plots = [];
      _updatedAt = null;
      _cached = false;
      _deviceId = null;
      _receipts.clear();
      _error = null;
    });
    await _restoreOperations();
    await _refresh();
  }

  Future<void> _restoreOperations() async {
    final scope = _scope;
    final device = await _db.device(scope);
    if (!mounted || scope != _scope) return;
    setState(() => _deviceId = device);
    final raw = await _storage.read(key: 'operations:$scope');
    if (!mounted || scope != _scope || raw == null) return;
    final cached = jsonDecode(raw) as Map;
    setState(() {
      _tasks = (cached['tasks'] as List).cast<Map<String, dynamic>>();
      _alerts = (cached['alerts'] as List).cast<Map<String, dynamic>>();
      _plots = (cached['plots'] as List).cast<Map<String, dynamic>>();
      _updatedAt = cached['updatedAt'] as String?;
      _cached = true;
    });
  }

  Future<void> _revalidate(OutboxData row) async {
    if (_busy || _offlineTest || row.scope != _scope) return;
    setState(() => _busy = true);
    try {
      final farms = await _api.list('/v1/farms', widget.session);
      if (!farms.any((farm) => farm['id'] == _farm)) {
        throw const ApiFailure(403, 'Acesso à fazenda não autorizado.');
      }
      await _db.retryAccessDenied(row.id, row.scope);
      await _sync.run(widget.session, _farm!, manual: true);
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _registerDevice() async {
    if (_busy || _farm == null || _deviceId == null || _offlineTest) return;
    setState(() => _busy = true);
    try {
      await _api.request(
        'POST',
        '/v1/sync/devices',
        token: widget.session.token,
        body: {'farmId': _farm, 'deviceId': _deviceId},
      );
      for (final row in await _db.rows(_scope)) {
        await _db.retryAccessDenied(row.id, _scope);
      }
      await _queueRefresh();
      if (mounted) {
        setState(() => _error = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aparelho cadastrado. A fila pode ser sincronizada.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify(Map<String, dynamic> batch) async {
    try {
      final result =
          await _api.request('GET', '/v1/verify/${batch['id']}') as Map;
      final chain = result['onChain'] as Map;
      final anchor = result['anchor'] as Map;
      final complete =
          result['valid'] == true &&
          result['status'] == 'ancorado' &&
          anchor['mode'] == 'evm' &&
          chain['checked'] == true &&
          chain['matches'] == true &&
          chain['revoked'] == false;
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            complete
                ? 'Prova conferida na rede'
                : 'Verificação ainda incompleta',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complete
                      ? 'A raiz recalculada confere com o contrato. Rede ${anchor['chainId']}.'
                      : 'Não há confirmação completa da rede nesta consulta. Consulte o estado e tente novamente.',
                ),
                const SizedBox(height: 16),
                SelectableText(
                  '${widget.session.baseUrl}/v1/verify/${batch['id']}',
                ),
                const SizedBox(height: 12),
                SelectableText('Transação: ${anchor['txRef'] ?? 'pendente'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text: '${widget.session.baseUrl}/v1/verify/${batch['id']}',
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Copiar link público'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _taskProof(String eventId) async {
    try {
      final receipt = await _api.request(
        'GET',
        '/v1/sync/events/$eventId/receipt',
        token: widget.session.token,
      );
      final batch = receipt['batch'] as Map<String, dynamic>?;
      if (!mounted) return;
      if (batch != null) {
        await _verify(batch);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento recebido; aguardando formação do lote.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  Future<void> _changeTaskStatus(String taskId, String status) async {
    if (_busy ||
        _offlineTest ||
        _farm == null ||
        ![
          'operador',
          'veterinario',
          'gerente',
          'administrador',
        ].contains(widget.session.role)) {
      return;
    }
    setState(() => _busy = true);
    try {
      await _api.setTaskStatus(widget.session, taskId, status);
      await _refresh();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              'Alteração de tarefa não confirmada. Atualize a lista antes de repetir. $error',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _notes.dispose();
    _api.close();
    unawaited(_db.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (i) => setState(() => _tab = i),
      destinations: const [
        NavigationDestination(
          key: ValueKey('tab-panel'),
          icon: Icon(Icons.space_dashboard),
          label: 'PAINEL',
        ),
        NavigationDestination(
          key: ValueKey('tab-map'),
          icon: Icon(Icons.map),
          label: 'MAPA',
        ),
        NavigationDestination(
          key: ValueKey('tab-scout'),
          icon: Icon(Icons.visibility),
          label: 'SCOUT',
        ),
        NavigationDestination(
          key: ValueKey('tab-herd'),
          icon: Icon(Icons.pets),
          label: 'REBANHO',
        ),
        NavigationDestination(
          key: ValueKey('tab-tasks'),
          icon: Icon(Icons.assignment),
          label: 'TAREFAS',
        ),
      ],
    ),
    body: AuthFrame(
      live: true,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'OPERAÇÃO CONECTADA',
                style: CommandType.display(size: 22),
              ),
            ),
            IconButton(
              tooltip: 'Sair da conta',
              onPressed: _busy ? null : widget.onSignOut,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        Text(
          '${widget.session.name} • ${widget.session.role}',
          style: CommandType.body(size: 13),
        ),
        const SizedBox(height: 12),
        const AuthNotice(
          'Dados operacionais abaixo vêm da API. Inspeção manual sem câmera, GPS ou modelo de IA; gera tarefa de revisão humana.',
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          AuthNotice(_error!),
        ],
        const SizedBox(height: 18),
        if (_farms.isNotEmpty)
          DropdownButtonFormField<String>(
            key: ValueKey(_farm),
            initialValue: _farm,
            isExpanded: true,
            items: _farms
                .map(
                  (f) => DropdownMenuItem<String>(
                    value: f['id'],
                    child: Text(f['name'], overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: _busy ? null : _switchFarm,
            decoration: const InputDecoration(
              labelText: 'Fazenda autorizada pela API',
            ),
          )
        else
          const Text(
            'Aguardando uma fazenda autorizada. Verifique a conexão e o cadastro.',
          ),
        TextButton(
          onPressed: _busy ? null : _load,
          child: const Text('Atualizar fazendas'),
        ),
        if (_updatedAt != null)
          Text(
            '${_cached ? 'CACHE • ' : 'API • '}Atualizado em $_updatedAt',
            style: CommandType.body(size: 11),
          ),
        const SizedBox(height: 16),
        ...switch (_tab) {
          0 => _dashboard(),
          1 => _map(),
          2 => _scout(),
          3 => [_scenario('rebanho')],
          4 => _tasksView(),
          _ => <Widget>[],
        },
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => setState(() => _tab = 0),
          child: const Text('Central de operação, irrigação e telemetria'),
        ),
      ],
    ),
  );
  List<Widget> _scout() => [
    if (_deviceId != null) ...[
      SelectableText('Aparelho: $_deviceId', style: CommandType.body(size: 10)),
      if (['gerente', 'administrador'].contains(widget.session.role))
        TextButton(
          key: const ValueKey('operation-register-device'),
          onPressed: _busy || _offlineTest ? null : _registerDevice,
          child: const Text('Cadastrar este aparelho na fazenda'),
        ),
    ],
    AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'REGISTRAR INSPEÇÃO MANUAL',
            style: CommandType.display(size: 16),
          ),
          const SizedBox(height: 12),
          AuthInput(
            label: 'OBSERVAÇÃO EM CAMPO',
            fieldKey: const ValueKey('operation-notes'),
            controller: _notes,
            icon: Icons.edit_note,
            maxLines: 3,
            hint: 'Descreva o que precisa de revisão humana',
          ),
          const SizedBox(height: 16),
          AuthAction(
            key: const ValueKey('operation-save'),
            label: _busy ? 'AGUARDE...' : 'SALVAR NO APARELHO',
            icon: Icons.save_outlined,
            onPressed:
                _busy || _farm == null || widget.session.role == 'auditor'
                ? null
                : _save,
          ),
        ],
      ),
    ),
    SwitchListTile(
      key: const ValueKey('operation-offline'),
      contentPadding: EdgeInsets.zero,
      title: const Text('Ensaio sem envio'),
      subtitle: const Text(
        'Suspende o sincronizador; permite salvar e reabrir a fila local.',
      ),
      value: _offlineTest,
      onChanged: _busy ? null : (v) => setState(() => _offlineTest = v),
    ),
    AuthAction(
      key: const ValueKey('operation-sync'),
      label: _busy ? 'SINCRONIZANDO...' : 'SINCRONIZAR E CONSULTAR API',
      icon: Icons.sync,
      onPressed: _busy || _offlineTest || _farm == null
          ? null
          : () => _synchronize(manual: true),
    ),
    const SizedBox(height: 22),
    Text(
      'FILA LOCAL • ${_queue.length} REGISTROS',
      style: CommandType.display(size: 16),
    ),
    if (_queue.isEmpty)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Nenhuma inspeção nesta conta/fazenda.'),
      ),
    for (final row in _queue) _eventCard(row),
    const SizedBox(height: 22),
  ];
  List<Widget> _tasksView() => [
    const AuthNotice(
      'Iniciar e concluir tarefas exige conexão com a API. A execução offline de tarefas ainda não está disponível.',
    ),
    Text(
      'TAREFAS DA API • ${_tasks.length}',
      style: CommandType.display(size: 16),
    ),
    for (final task in _tasks)
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task['title'], style: CommandType.body()),
              if (task['description'] != null)
                Text(task['description'], style: CommandType.body(size: 12)),
              Text(
                '${switch (task['status']) {
                  'pendente' => 'Pendente',
                  'em_progresso' => 'Em andamento',
                  'concluida' => 'Concluída',
                  _ => task['status'],
                }} • ${task['priority']}',
                style: CommandType.label(size: 11),
              ),
              if (task['source_event_id'] != null)
                SelectableText(
                  'Evento: ${task['source_event_id']}',
                  style: CommandType.body(size: 10),
                ),
              if (task['source_event_id'] != null)
                TextButton(
                  onPressed: () =>
                      _taskProof(task['source_event_id'] as String),
                  child: const Text('Consultar prova deste evento'),
                ),
              if ([
                'operador',
                'veterinario',
                'gerente',
                'administrador',
              ].contains(widget.session.role))
                Wrap(
                  spacing: 12,
                  children: [
                    if (task['status'] == 'pendente')
                      TextButton(
                        key: ValueKey('task-start:${task['id']}'),
                        onPressed: _busy || _offlineTest
                            ? null
                            : () =>
                                  _changeTaskStatus(task['id'], 'em_progresso'),
                        child: const Text('Iniciar tarefa'),
                      ),
                    if (task['status'] == 'em_progresso')
                      TextButton(
                        key: ValueKey('task-complete:${task['id']}'),
                        onPressed: _busy || _offlineTest
                            ? null
                            : () => _changeTaskStatus(task['id'], 'concluida'),
                        child: const Text('Concluir tarefa'),
                      ),
                    if (task['status'] == 'concluida')
                      const Text(
                        'Concluída pela API',
                        style: TextStyle(color: CommandColors.primary),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    if (_tasks.isEmpty)
      const AuthNotice('Nenhuma tarefa recebida nesta fazenda.'),
    TextButton(
      onPressed: _busy ? null : _refresh,
      child: const Text('Atualizar tarefas'),
    ),
  ];
  Widget _scenario(String section) => _farm == null
      ? const Text('Selecione uma fazenda.')
      : ScenarioView(
          key: ValueKey('scenario:$_scope:$section'),
          session: widget.session,
          farmId: _farm!,
          section: section,
          offline: _offlineTest,
          onChanged: _refresh,
        );
  List<Widget> _dashboard() => [
    Text('PAINEL DA FAZENDA', style: CommandType.display(size: 20)),
    _scenario('painel'),
    const SizedBox(height: 16),
    AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarefas pendentes: ${_tasks.where((t) => t['status'] != 'concluida').length}',
          ),
          Text(
            'Alertas abertos: ${_alerts.where((a) => a['status'] != 'resolvido').length}',
          ),
          Text('Áreas cadastradas: ${_plots.length}'),
          Text(
            'Envios locais aguardando confirmação: ${_queue.where((r) => r.status != 'synced').length}',
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    TextButton(
      onPressed: () => setState(() => _tab = 2),
      child: const Text('Registrar inspeção no Scout'),
    ),
    TextButton(
      onPressed: () => setState(() => _tab = 4),
      child: const Text('Consultar tarefas da API'),
    ),
    if (_alerts.isEmpty)
      const AuthNotice(
        'Nenhum alerta recebido. Inspeções manuais geram revisão humana; não geram previsões de IA.',
      ),
    for (final alert in _alerts)
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert['title'] as String),
              Text('${alert['severity']} • ${alert['status']}'),
            ],
          ),
        ),
      ),
    const SizedBox(height: 16),
    TextButton(
      onPressed: _busy ? null : _refresh,
      child: const Text('Atualizar painel'),
    ),
  ];
  List<Widget> _map() => [
    _scenario('mapa'),
    Text('ÁREAS DA FAZENDA • API', style: CommandType.display(size: 20)),
    const AuthNotice(
      'Limites cadastrados em GeoJSON. Posição do aparelho, satélite e NDVI ainda não estão conectados.',
    ),
    if (_plots.isEmpty) const Text('Nenhuma área cadastrada nesta fazenda.'),
    for (final plot in _plots)
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plot['name'] as String, style: CommandType.body()),
              Text('${plot['kind']}'),
              SelectableText(
                'Área: ${plot['id']}',
                style: CommandType.body(size: 10),
              ),
              SizedBox(
                height: 180,
                child: CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _BoundaryPainter(plot['boundary']),
                ),
              ),
            ],
          ),
        ),
      ),
  ];
  Widget _eventCard(OutboxData row) {
    final receipt = _receipts[row.id];
    final batch = receipt?['batch'] as Map<String, dynamic>?;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AuthCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(row.id, style: CommandType.body(size: 11)),
            Text(switch (row.status) {
              'pending' => 'Pendente de envio',
              'sending' => 'Enviando',
              'retry' => 'Aguardando nova tentativa',
              'synced' => 'Ingestão confirmada • ${row.ack}',
              'paused' => 'Reconecte à sua conta',
              _ => 'Rejeitado; original preservado',
            }, style: CommandType.label(size: 11)),
            if (row.error != null)
              Text(
                row.error!,
                style: CommandType.body(size: 11, color: CommandColors.error),
              ),
            if (row.status == 'rejected' && row.httpStatus == 403)
              TextButton(
                onPressed: _busy || _offlineTest
                    ? null
                    : () => _revalidate(row),
                child: const Text('Revalidar após cadastro do aparelho'),
              ),
            if (receipt != null)
              Text(
                'Tarefas deste evento: ${(receipt['tasks'] as List).length}',
                style: CommandType.body(size: 12),
              ),
            if (row.status == 'synced')
              Text(
                batch == null
                    ? 'Aguardando formação do lote'
                    : 'Lote ${batch['status']} • ${batch['chain_id'] ?? 'rede pendente'}',
                style: CommandType.body(size: 12),
              ),
            if (batch != null)
              TextButton(
                onPressed: () => _verify(batch),
                child: const Text('Verificação pública da prova'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BoundaryPainter extends CustomPainter {
  _BoundaryPainter(this.boundary);
  final dynamic boundary;
  @override
  void paint(Canvas canvas, Size size) {
    if (boundary is! Map || boundary['type'] != 'Polygon') return;
    final rings = boundary['coordinates'] as List?;
    if (rings == null || rings.isEmpty) return;
    final points = (rings.first as List)
        .map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList();
    if (points.isEmpty) return;
    final bounds = points.fold(
      Rect.fromPoints(points.first, points.first),
      (Rect r, p) => r.expandToInclude(Rect.fromPoints(p, p)),
    );
    if (bounds.width == 0 || bounds.height == 0) return;
    final sx = (size.width - 24) / bounds.width,
        sy = (size.height - 24) / bounds.height;
    final scale = sx < sy ? sx : sy;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = 12 + (points[i].dx - bounds.left) * scale;
      final y = size.height - 12 - (points[i].dy - bounds.top) * scale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()..color = CommandColors.primary.withValues(alpha: .15),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = CommandColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BoundaryPainter oldDelegate) =>
      oldDelegate.boundary != boundary;
}
