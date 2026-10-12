import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../app/design_system.dart';
import '../../core/sync/operations_api.dart';
import '../auth/auth_widgets.dart';

class ScenarioView extends StatefulWidget {
  const ScenarioView({
    required this.session,
    required this.farmId,
    required this.section,
    required this.offline,
    required this.onChanged,
    super.key,
  });
  final ApiSession session;
  final String farmId, section;
  final bool offline;
  final Future<void> Function() onChanged;
  @override
  State<ScenarioView> createState() => _ScenarioViewState();
}

class _ScenarioViewState extends State<ScenarioView> {
  late final api = OperationsApi(widget.session.baseUrl);
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? data, pending, receipt;
  String? error, message;
  bool busy = false, cached = false, criticalOnly = false;
  String selectedAnimal = 'BR-003', selectedPoint = '';
  Timer? timer;
  String get cacheKey => 'scenario:${widget.session.scope(widget.farmId)}';
  bool get canAct =>
      widget.session.role != 'auditor' && !widget.offline && !busy;
  @override
  void initState() {
    super.initState();
    load();
    timer = Timer.periodic(const Duration(seconds: 20), (_) => load());
  }

  @override
  void dispose() {
    timer?.cancel();
    api.close();
    super.dispose();
  }

  Future<void> load() async {
    try {
      if (data == null) {
        final raw = await storage.read(key: cacheKey);
        if (raw != null && mounted) {
          setState(() {
            data = jsonDecode(raw);
            cached = true;
          });
        }
      }
      if (widget.offline) return;
      final result = await api.request(
        'GET',
        '/v1/demo/farms/${widget.farmId}',
        token: widget.session.token,
      );
      await storage.write(key: cacheKey, value: jsonEncode(result));
      if (mounted) {
        setState(() {
          data = (result as Map).cast<String, dynamic>();
          cached = false;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    }
  }

  Future<void> action(String command, [String? target]) async {
    if (!canAct) return;
    final attempt =
        pending?['command'] == command && pending?['target'] == target
        ? pending!
        : {'id': const Uuid().v4(), 'command': command, 'target': ?target};
    setState(() {
      busy = true;
      pending = attempt;
      error = null;
    });
    try {
      final result = await api.request(
        'POST',
        '/v1/demo/farms/${widget.farmId}/actions',
        token: widget.session.token,
        body: attempt,
      );
      if (result['id'] != attempt['id'] || result['simulated'] != true) {
        throw const ApiFailure(0, 'Confirmação incompatível');
      }
      if (!mounted) return;
      setState(() {
        pending = null;
        message = '${result['label']}\nEvento: ${result['eventId']}';
      });
      await load();
      await widget.onChanged();
    } catch (e) {
      if (mounted) {
        setState(
          () => error =
              'Ação não confirmada: $e. Repita o mesmo comando para consultar a tentativa.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget control(String label, String command, [String? target]) =>
      FilledButton.tonal(
        onPressed: canAct ? () => action(command, target) : null,
        child: Text(label),
      );
  Future<void> solana(String eventId, bool publish) async {
    if (busy || widget.offline) return;
    setState(() => busy = true);
    try {
      final result = await api.request(
        publish ? 'POST' : 'GET',
        publish ? '/v1/solana/receipts/$eventId' : '/v1/solana/verify/$eventId',
        token: widget.session.token,
        body: publish ? {} : null,
      );
      if (mounted) {
        setState(() => receipt = (result as Map).cast<String, dynamic>());
      }
    } catch (e) {
      if (mounted) setState(() => error = 'Recibo Solana não confirmado: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget card(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: CommandType.display(size: 16)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return Column(
        children: [
          const AuthNotice('Carregando cenário simulado da API.'),
          if (error != null) AuthNotice(error!),
          TextButton(onPressed: load, child: const Text('Atualizar cenário')),
        ],
      );
    }
    final state = data!['state'] as Map;
    final irrigation = state['irrigation'] as Map,
        drone = state['drone'] as Map;
    final animals = state['animals'] as List;
    final animal =
        animals.firstWhere(
              (a) => a['id'] == selectedAnimal,
              orElse: () => animals.first,
            )
            as Map;
    final telemetry = data!['telemetry'] as Map;
    final points = (telemetry['points'] as List).cast<Map>();
    final section = widget.section;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthNotice(
          'CENÁRIO SIMULADO • ${cached || widget.offline ? 'CACHE' : 'API'} • versão ${state['version']}\nLeitura: ${telemetry['sampledAt']}\nAs ações não controlam equipamentos físicos.',
        ),
        if (error != null) AuthNotice(error!),
        if (message != null)
          SelectableText(message!, style: CommandType.body(size: 12)),
        TextButton(
          onPressed: busy ? null : load,
          child: const Text('Atualizar telemetria'),
        ),
        if (section == 'painel') ...[
          card('IRRIGAÇÃO • IRR-01', [
            Text(
              '${irrigation['status']} • umidade ${irrigation['moisture']}%\nPressão ${irrigation['pressure']} bar • vazão ${irrigation['flow']} m³/h',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                control('Simular falha de irrigação', 'irrigation.fail'),
                control('Reparar irrigação', 'irrigation.repair'),
                control('Iniciar irrigação', 'irrigation.start'),
                control('Parar irrigação', 'irrigation.stop'),
              ],
            ),
          ]),
          card('INSPEÇÃO DE PRAGAS', [
            Text(
              state['pest'] == true
                  ? 'Ocorrência aberta'
                  : 'Sem ocorrência aberta',
            ),
            Wrap(
              spacing: 8,
              children: [
                control('Gerar ocorrência', 'pest.detect'),
                control('Concluir inspeção', 'pest.resolve'),
              ],
            ),
          ]),
          card('UMIDADE • SÉRIE FICTÍCIA', [
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _SeriesPainter(
                  (telemetry['series'] as List).cast<Map>(),
                ),
                size: const Size(double.infinity, 120),
              ),
            ),
            const Text('Histórico simulado de 60 minutos • %'),
          ]),
        ],
        if (['mapa', 'painel'].contains(section))
          card('MAPA OPERACIONAL', [
            SizedBox(
              height: 300,
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: CustomPaint(
                  size: const Size(340, 300),
                  painter: ScenarioMapPainter(
                    (data!['plots'] as List).cast<Map>(),
                    points,
                  ),
                ),
              ),
            ),
            const Text(
              'Arraste e use dois dedos para aproximar. Selecione um ativo abaixo.',
            ),
            Wrap(
              spacing: 6,
              children: points
                  .map(
                    (p) => ActionChip(
                      label: Text('${p['label']} • ${p['status']}'),
                      onPressed: () => setState(
                        () => selectedPoint =
                            '${p['label']} • ${p['status']}\n${p['lat'] ?? 'sem latitude'}, ${p['lon'] ?? 'sem longitude'}',
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (selectedPoint.isNotEmpty) SelectableText(selectedPoint),
          ]),
        if (['mapa', 'painel'].contains(section))
          card('DRONE AERO-01', [
            Text(
              '${drone['status']} • bateria ${drone['battery']}% • sinal ${drone['signal']}%',
            ),
            Wrap(
              spacing: 8,
              children: [
                control('Enviar para vistoria', 'drone.dispatch'),
                control('Retornar à base', 'drone.return'),
              ],
            ),
          ]),
        if (section == 'rebanho') ...[
          SwitchListTile(
            title: const Text('Somente animais em atenção'),
            value: criticalOnly,
            onChanged: (v) => setState(() => criticalOnly = v),
          ),
          Wrap(
            spacing: 8,
            children: animals
                .where((a) => !criticalOnly || a['status'] == 'atencao')
                .map(
                  (a) => ChoiceChip(
                    label: Text('${a['id']} • ${a['name']}'),
                    selected: selectedAnimal == a['id'],
                    onSelected: (_) => setState(() => selectedAnimal = a['id']),
                  ),
                )
                .toList(),
          ),
          card('ANIMAL ${animal['id']}', [
            Text(
              '${animal['status']} • ${animal['temperature']} °C • ${animal['heartRate']} bpm\nColeira ${animal['battery']}% • piquete ${(animal['plot'] as int) + 1}\n${animal['vaccinated'] == true ? 'Vacinado' : 'Vacinação pendente'}',
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                control('Registrar atendimento', 'animal.treat', animal['id']),
                control(
                  'Registrar vacinação',
                  'animal.vaccinate',
                  animal['id'],
                ),
                control('Transferir de piquete', 'animal.move', animal['id']),
              ],
            ),
          ]),
        ],
        if (section == 'painel')
          card('ESTOQUE E APOIO', [
            Text(
              'Ração: ${state['stock']['feedKg']} kg • vacinas: ${state['stock']['vaccines']} doses\nChamado: ${state['support']}',
            ),
            Wrap(
              spacing: 8,
              children: [
                control('Receber reposição', 'stock.replenish'),
                control('Solicitar apoio ao Comando', 'support.request'),
              ],
            ),
          ]),
        if (receipt != null)
          card('RECIBO SOLANA DEVNET', [
            Text(
              receipt!['valid'] == true && receipt!['checked'] == true
                  ? 'Confirmado e conferido na rede'
                  : receipt!['configured'] == false
                  ? 'Aguardando configuração Solana no servidor'
                  : 'Estado: ${receipt!['status']} • ainda sem confirmação',
            ),
            if (receipt!['explorer'] != null)
              SelectableText(
                receipt!['explorer'],
                style: CommandType.body(size: 12),
              ),
          ]),
        card('HISTÓRICO DO CENÁRIO', [
          for (final h in state['history'] as List)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${h['at']}\n${h['label']}',
                    style: CommandType.body(size: 12),
                  ),
                  if (h['eventId'] != null)
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: canAct
                              ? () => solana(h['eventId'], true)
                              : null,
                          child: const Text('Publicar recibo Solana'),
                        ),
                        TextButton(
                          onPressed: busy || widget.offline
                              ? null
                              : () => solana(h['eventId'], false),
                          child: const Text('Conferir recibo Solana'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          if ((state['history'] as List).isEmpty)
            const Text('Nenhuma ação registrada.'),
        ]),
      ],
    );
  }
}

class ScenarioMapPainter extends CustomPainter {
  ScenarioMapPainter(this.plots, this.points);
  final List<Map> plots, points;
  @override
  void paint(Canvas canvas, Size size) {
    final rings = plots
        .map((p) => (p['boundary']['coordinates'][0] as List))
        .toList();
    final coords = rings
        .expand((r) => r)
        .map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()))
        .toList();
    if (coords.isEmpty) return;
    final bounds = coords.fold(
      Rect.fromPoints(coords.first, coords.first),
      (Rect b, p) => b.expandToInclude(Rect.fromPoints(p, p)),
    );
    if (bounds.width <= 0 || bounds.height <= 0) return;
    final scale =
        (size.width - 32) / bounds.width < (size.height - 32) / bounds.height
        ? (size.width - 32) / bounds.width
        : (size.height - 32) / bounds.height;
    Offset project(num lon, num lat) => Offset(
      16 + (lon - bounds.left) * scale,
      size.height - 16 - (lat - bounds.top) * scale,
    );
    for (var i = 0; i < rings.length; i++) {
      final path = Path();
      for (var j = 0; j < rings[i].length; j++) {
        final p = project(rings[i][j][0], rings[i][j][1]);
        if (j == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()..color = CommandColors.primary.withValues(alpha: .12),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = CommandColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    for (final p in points) {
      if (p['lat'] is! num || p['lon'] is! num) continue;
      final point = project(p['lon'], p['lat']);
      final color = ['falha', 'atencao'].contains(p['status'])
          ? CommandColors.error
          : p['kind'] == 'drone'
          ? CommandColors.cyan
          : CommandColors.primary;
      canvas.drawCircle(point, 5, Paint()..color = color);
      final text = TextPainter(
        text: TextSpan(
          text: p['label'],
          style: TextStyle(color: color, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, point + const Offset(6, -5));
    }
  }

  @override
  bool shouldRepaint(ScenarioMapPainter oldDelegate) => true;
}

class _SeriesPainter extends CustomPainter {
  _SeriesPainter(this.series);
  final List<Map> series;
  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = i * size.width / (series.length - 1),
          y = size.height - (series[i]['moisture'] as num) * size.height / 100;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = CommandColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_SeriesPainter oldDelegate) => true;
}
