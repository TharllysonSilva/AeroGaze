import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../../app/design_system.dart';
import '../../core/sync/operations_api.dart';
import '../auth/auth_widgets.dart';
import 'scenario_presentation.dart';

class ScenarioView extends StatefulWidget {
  const ScenarioView({
    required this.session,
    required this.farmId,
    required this.section,
    required this.offline,
    required this.onChanged,
    this.onNavigate,
    super.key,
  });
  final ValueChanged<int>? onNavigate;
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
  bool busy = false, cached = false;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cached || widget.offline)
          const AuthNotice('CACHE • modo sem envio. Ações exigem conexão.'),
        if (error != null) AuthNotice(error!),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SelectableText(message!, style: CommandType.body(size: 12)),
          ),
        ScenarioPresentation(
          data: data!,
          section: widget.section,
          canAct: canAct,
          onAction: action,
          onRefresh: load,
          onSolana: solana,
          onNavigate: widget.onNavigate,
        ),
        if (receipt != null)
          card('RECIBO SOLANA DEVNET', [
            Text(
              receipt!['valid'] == true && receipt!['checked'] == true
                  ? 'Confirmado e conferido na rede'
                  : 'Aguardando confirmação: ${receipt!['status']}',
            ),
            if (receipt!['explorer'] != null)
              SelectableText(receipt!['explorer']),
          ]),
      ],
    );
  }
}
