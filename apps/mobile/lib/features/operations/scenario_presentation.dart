import 'package:flutter/material.dart';
import '../../app/design_system.dart';
import '../../core/design/reference_photo.dart';
import 'scenario_painters.dart';

/// Reference composition backed by the shared, explicitly simulated API scenario.
class ScenarioPresentation extends StatefulWidget {
  const ScenarioPresentation({
    required this.data,
    required this.section,
    required this.canAct,
    required this.onAction,
    required this.onRefresh,
    required this.onSolana,
    this.onNavigate,
    super.key,
  });
  final Map<String, dynamic> data;
  final String section;
  final bool canAct;
  final void Function(String, [String?]) onAction;
  final VoidCallback onRefresh;
  final void Function(String, bool) onSolana;
  final ValueChanged<int>? onNavigate;
  @override
  State<ScenarioPresentation> createState() => _ScenarioPresentationState();
}

class _ScenarioPresentationState extends State<ScenarioPresentation> {
  String selected = 'BR-003', layer = 'Culturas';
  bool critical = false, showAll = false;
  final transform = TransformationController();
  Map get state => widget.data['state'] as Map;
  Map get irrigation => state['irrigation'] as Map;
  Map get telemetry => widget.data['telemetry'] as Map;
  List<Map> get animals => (state['animals'] as List).cast<Map>();
  @override
  void dispose() {
    transform.dispose();
    super.dispose();
  }

  Widget title(String text) => Text(text, style: CommandType.label(size: 12));
  Widget panel(String label, List<Widget> children, {Color? accent}) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: CommandPanel(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [title(label), const SizedBox(height: 18), ...children],
      ),
    ),
  );
  Widget button(
    String label,
    String command, {
    String? target,
    IconData? icon,
  }) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: FilledButton.icon(
      onPressed: widget.canAct ? () => widget.onAction(command, target) : null,
      icon: Icon(icon ?? Icons.check_circle_outline, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        backgroundColor: CommandColors.primaryContainer,
        foregroundColor: CommandColors.lowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
  Widget metric(
    String label,
    String value, {
    Color color = CommandColors.primary,
  }) => CommandPanel(
    color: CommandColors.lowest,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title(label),
        const SizedBox(height: 8),
        Text(value, style: CommandType.display(size: 25, color: color)),
      ],
    ),
  );
  Widget pair(Widget a, Widget b) => Row(
    children: [
      Expanded(child: a),
      const SizedBox(width: 12),
      Expanded(child: b),
    ],
  );
  Widget alert(
    String label,
    String description,
    IconData icon,
    Color color,
    VoidCallback? tap,
  ) => Material(
    color: color.withValues(alpha: .10),
    borderRadius: BorderRadius.circular(9),
    child: InkWell(
      onTap: tap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: CommandType.body(weight: 700)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: CommandType.body(
                      size: 12,
                      color: CommandColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget get history => panel('ATIVIDADES RECENTES', [
    if ((state['history'] as List).isEmpty)
      const Text('Nenhuma operação registrada.'),
    for (final h in (state['history'] as List).take(8))
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.circle, size: 9, color: CommandColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${h['label']}', style: CommandType.body(weight: 700)),
                  Text('${h['at']}', style: CommandType.label(size: 9)),
                  if (h['eventId'] != null)
                    Wrap(
                      children: [
                        TextButton(
                          onPressed: () => widget.onSolana(h['eventId'], false),
                          child: const Text('Conferir recibo Solana'),
                        ),
                        if (widget.canAct)
                          TextButton(
                            onPressed: () =>
                                widget.onSolana(h['eventId'], true),
                            child: const Text('Publicar recibo Solana'),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
  ]);
  List<Widget> dashboard() {
    final attention = animals.where((a) => a['status'] == 'atencao').length;
    final score = ((animals.length - attention) * 100 / animals.length).round();
    return [
      Text(
        'Status da Fazenda: ${irrigation['status'] == 'falha' ? 'Atenção à irrigação' : 'Operação sob acompanhamento'}.',
        style: CommandType.body(color: CommandColors.muted),
      ),
      const SizedBox(height: 32),
      panel('ÍNDICE DE SAÚDE • CENÁRIO', [
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: CommandColors.high,
                    color: CommandColors.primary,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: CommandType.display(
                        size: 54,
                        color: CommandColors.primary,
                      ),
                    ),
                    title('/100'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '$attention animais em atenção • ${animals.length} monitorados',
            style: CommandType.body(size: 12, color: CommandColors.primary),
          ),
        ),
      ]),
      panel('ALERTAS OPERACIONAIS', [
        alert(
          state['pest'] == true
              ? 'Risco de Pragas Detectado'
              : 'Inspeção de Pragas',
          state['pest'] == true
              ? 'Ocorrência aberta • toque para inspecionar'
              : 'Sem ocorrência aberta • simular inspeção',
          Icons.pest_control,
          CommandColors.error,
          () => widget.onNavigate?.call(2),
        ),
        const SizedBox(height: 16),
        alert(
          irrigation['status'] == 'falha'
              ? 'Falha de Irrigação'
              : 'Previsão de Irrigação',
          '${irrigation['status']} • umidade ${irrigation['moisture']}% • ver mapa',
          Icons.water_drop_outlined,
          CommandColors.cyan,
          () => widget.onNavigate?.call(1),
        ),
      ]),
      panel('RESUMO DO REBANHO', [
        pair(
          metric('SAUDÁVEIS', '${animals.length - attention}'),
          metric('ANOMALIAS', '$attention', color: CommandColors.error),
        ),
        TextButton.icon(
          onPressed: () => widget.onNavigate?.call(3),
          icon: const Icon(Icons.pets),
          label: const Text('Ver detalhes'),
        ),
      ]),
      CommandPanel(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 180,
              child: ReferencePhoto(
                asset: 'assets/reference/aerogaze_dashboard_pt.png',
                region: Rect.fromLTWH(16, 1100, 358, 160),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoramento do cenário',
                    style: CommandType.display(size: 20),
                  ),
                  Text(
                    'AERO-01 • ${state['drone']['status']} • telemetria simulada',
                    style: CommandType.body(size: 12),
                  ),
                  FilledButton(
                    onPressed: () => widget.onNavigate?.call(1),
                    child: const Text('EXPANDIR MAPA'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      panel('CONTROLE DE IRRIGAÇÃO', [
        Text(
          '${irrigation['pressure']} bar • ${irrigation['flow']} m³/h',
          style: CommandType.display(size: 20, color: CommandColors.blue),
        ),
        button(
          'Simular falha de irrigação',
          'irrigation.fail',
          icon: Icons.warning_amber,
        ),
        button('Reparar irrigação', 'irrigation.repair', icon: Icons.build),
        pair(
          ExpandedButton(
            label: 'Iniciar irrigação',
            onPressed: widget.canAct
                ? () => widget.onAction('irrigation.start')
                : null,
          ),
          ExpandedButton(
            label: 'Parar irrigação',
            onPressed: widget.canAct
                ? () => widget.onAction('irrigation.stop')
                : null,
          ),
        ),
      ]),
      panel('LOGÍSTICA E APOIO', [
        Text(
          'Ração ${state['stock']['feedKg']} kg • ${state['stock']['vaccines']} doses',
        ),
        button('Receber reposição', 'stock.replenish', icon: Icons.inventory_2),
        button(
          'Solicitar apoio ao Comando',
          'support.request',
          icon: Icons.support_agent,
        ),
      ]),
      history,
    ];
  }

  List<Widget> map() {
    final points = (telemetry['points'] as List)
        .cast<Map>()
        .where(
          (p) =>
              layer == 'Culturas' ||
              (layer == 'Gado' ? p['kind'] == 'animal' : p['kind'] != 'animal'),
        )
        .toList();
    return [
      SizedBox(
        height: 530,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              const Positioned.fill(
                child: ReferencePhoto(
                  asset: 'assets/reference/aerogaze_mapa_pt.png',
                  region: Rect.fromLTWH(570, 116, 136, 1330),
                ),
              ),
              Positioned.fill(
                child: ColoredBox(color: Colors.black.withValues(alpha: .35)),
              ),
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: transform,
                  minScale: 1,
                  maxScale: 5,
                  child: CustomPaint(
                    size: const Size(360, 530),
                    painter: ScenarioMapPainter(
                      (widget.data['plots'] as List).cast<Map>(),
                      points,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: CommandPanel(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      for (final value in ['Culturas', 'Gado', 'Sensores'])
                        TextButton.icon(
                          onPressed: () => setState(() => layer = value),
                          icon: Icon(
                            value == 'Gado'
                                ? Icons.pets
                                : value == 'Sensores'
                                ? Icons.sensors
                                : Icons.grass,
                          ),
                          label: Text(value.toUpperCase()),
                          style: TextButton.styleFrom(
                            backgroundColor: layer == value
                                ? CommandColors.primaryContainer
                                : null,
                            foregroundColor: layer == value
                                ? CommandColors.lowest
                                : CommandColors.muted,
                          ),
                        ),
                      IconButton(
                        tooltip: 'Aproximar mapa',
                        onPressed: () =>
                            transform.value = transform.value.clone()
                              ..scaleByDouble(1.3, 1.3, 1, 1),
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        tooltip: 'Afastar mapa',
                        onPressed: () {
                          if (transform.value.getMaxScaleOnAxis() > 1) {
                            transform.value = transform.value.clone()
                              ..scaleByDouble(1 / 1.3, 1 / 1.3, 1, 1);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      IconButton(
                        tooltip: 'Restaurar camadas e zoom',
                        onPressed: () {
                          transform.value = Matrix4.identity();
                          setState(() => layer = 'Culturas');
                        },
                        icon: const Icon(Icons.layers),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: CommandPanel(
                  accent: irrigation['status'] == 'falha'
                      ? CommandColors.error
                      : CommandColors.primary,
                  color: irrigation['status'] == 'falha'
                      ? const Color(0xFF351A19)
                      : CommandColors.panel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title(
                        irrigation['status'] == 'falha'
                            ? 'ALERTA CRÍTICO'
                            : 'IRRIGAÇÃO • IRR-01',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        irrigation['status'] == 'falha'
                            ? 'FALHA DE IRRIGAÇÃO'
                            : '${irrigation['status']}'.toUpperCase(),
                        style: CommandType.display(size: 20),
                      ),
                      Text(
                        'Pressão ${irrigation['pressure']} bar • dados simulados',
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          button(
                            'Desligar',
                            'irrigation.stop',
                            icon: Icons.power_settings_new,
                          ),
                          button(
                            'Reparar irrigação',
                            'irrigation.repair',
                            icon: Icons.build,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      title('POLÍGONOS CADASTRADOS • POSIÇÕES FICTÍCIAS'),
      Wrap(
        spacing: 6,
        children: points
            .map(
              (p) => ActionChip(
                label: Text('${p['label']}'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text('${p['label']}'),
                    content: Text(
                      '${p['status']}\nLatitude: ${p['lat']}\nLongitude: ${p['lon']}\nPosição simulada, sem GPS físico.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('Fechar'),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
      panel('DRONE AERO-01', [
        Text(
          '${state['drone']['status']} • bateria ${state['drone']['battery']}%',
        ),
        button(
          'Enviar para vistoria',
          'drone.dispatch',
          icon: Icons.flight_takeoff,
        ),
        button('Retornar à base', 'drone.return', icon: Icons.flight_land),
      ]),
      history,
    ];
  }

  List<Widget> herd() {
    final a = animals.firstWhere(
      (a) => a['id'] == selected,
      orElse: () => animals.first,
    );
    final attention = animals.where((a) => a['status'] == 'atencao').length;
    final stats = (telemetry['animalStats'] as List? ?? [])
        .cast<Map>()
        .where((v) => v['id'] == a['id'])
        .firstOrNull;
    return [
      title('MÓDULO DE VIGILÂNCIA BIOLÓGICA'),
      Text('Gestão de Rebanho', style: CommandType.display(size: 28)),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FilterChip(
            label: const Text('Filtrar atenção'),
            selected: critical,
            onSelected: (v) => setState(() => critical = v),
          ),
          FilledButton.icon(
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Sincronizar sensores'),
            style: FilledButton.styleFrom(
              backgroundColor: CommandColors.primaryContainer,
              foregroundColor: CommandColors.lowest,
            ),
          ),
        ],
      ),
      const SizedBox(height: 18),
      panel('UNIDADES DE MONITORAMENTO', [
        for (final animal
            in animals
                .where((a) => !critical || a['status'] == 'atencao')
                .take(showAll ? animals.length : 4))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: selected == animal['id']
                  ? CommandColors.high
                  : CommandColors.lowest,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                onTap: () => setState(() => selected = animal['id']),
                borderRadius: BorderRadius.circular(9),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 38,
                        height: 38,
                        child: ReferencePhoto(
                          asset: 'assets/reference/aerogaze_rebanho_pt.png',
                          region: Rect.fromLTWH(38, 241, 32, 33),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bovino #${animal['id']}',
                              style: CommandType.body(weight: 700),
                            ),
                            Text(
                              '${animal['name']} • Piquete ${(animal['plot'] as int) + 1}',
                              style: CommandType.label(size: 9),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        animal['status'] == 'atencao' ? 'Atenção' : 'Saudável',
                        style: CommandType.body(
                          size: 10,
                          color: animal['status'] == 'atencao'
                              ? CommandColors.error
                              : CommandColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ]),
      TextButton(
        onPressed: () => setState(() => showAll = !showAll),
        child: Text(
          showAll ? 'Mostrar resumo' : 'Ver todos os ${animals.length} animais',
        ),
      ),
      panel('OCUPAÇÃO POR STATUS', [
        LinearProgressIndicator(
          value: (animals.length - attention) / animals.length,
          color: CommandColors.primary,
          backgroundColor: CommandColors.error,
        ),
        const SizedBox(height: 12),
        Text('${animals.length - attention} saudáveis • $attention em atenção'),
      ]),
      panel('IDENTIFICADOR • ${a['id']}', [
        const SizedBox(
          height: 110,
          child: ReferencePhoto(
            asset: 'assets/reference/aerogaze_rebanho_pt.png',
            region: Rect.fromLTWH(13, 596, 294, 44),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(
              width: 58,
              height: 73,
              child: ReferencePhoto(
                asset: 'assets/reference/aerogaze_rebanho_pt.png',
                region: Rect.fromLTWH(33, 664, 58, 73),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text('${a['name']}', style: CommandType.display(size: 32)),
            ),
          ],
        ),
        Text('${a['status']} • coleira ${a['battery']}%'),
        const SizedBox(height: 16),
        pair(
          metric(
            'FREQ. CARDÍACA',
            '${a['heartRate']} bpm',
            color: CommandColors.blue,
          ),
          metric('TEMPERATURA', '${a['temperature']} °C'),
        ),
        const SizedBox(height: 12),
        pair(
          metric('PASTO (HOJE)', '${stats?['pastureHours'] ?? '—'} horas'),
          metric('PESO EST.', '${stats?['weightKg'] ?? '—'} kg'),
        ),
      ]),
      panel('ANÁLISE METABÓLICA • SIMULADA', [
        Text(
          'Atividade fictícia • últimos 60 minutos',
          style: CommandType.body(size: 12),
        ),
        SizedBox(
          height: 140,
          child: CustomPaint(
            painter: SeriesPainter(
              ((stats?['activity'] as List?) ?? [])
                  .map((v) => <String, dynamic>{'moisture': v['value']})
                  .toList(),
            ),
            size: const Size(double.infinity, 140),
          ),
        ),
        Text(
          'Risco de acidose: ${stats?['acidosisRisk'] ?? '—'} • Ruminação: ${stats?['rumination'] ?? '—'}\nEstresse térmico: ${stats?['thermalStress'] ?? '—'}',
          style: CommandType.body(size: 12),
        ),
        const Text('Métricas fictícias, sem inferência clínica real.'),
      ]),
      button(
        'ADICIONAR TRATAMENTO',
        'animal.treat',
        target: a['id'],
        icon: Icons.medical_services,
      ),
      button(
        'REGISTRAR VACINAÇÃO',
        'animal.vaccinate',
        target: a['id'],
        icon: Icons.vaccines,
      ),
      button(
        'MOVER DE PASTO',
        'animal.move',
        target: a['id'],
        icon: Icons.move_down,
      ),
      const SizedBox(height: 24),
      history,
    ];
  }

  List<Widget> scout() {
    final crop = telemetry['crop'] as Map?;
    return [
      panel('ANÁLISE EM TEMPO REAL • SIMULADA', [
        title('ÍNDICE DE CLOROFILA'),
        Text(
          '${crop?['chlorophyll'] ?? '—'} NIM',
          style: CommandType.display(size: 38),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (crop?['chlorophyll'] as num? ?? 0).toDouble(),
          color: CommandColors.primary,
        ),
        const SizedBox(height: 24),
        title('CONFIANÇA ILUSTRATIVA'),
        Text(
          '${crop?['confidence'] ?? '—'}%',
          style: CommandType.display(size: 32),
        ),
        const SizedBox(height: 20),
        CommandPanel(
          color: CommandColors.high,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title('SENSORES DE SOLO • CENÁRIO'),
              const SizedBox(height: 16),
              pair(
                metric('UMIDADE', '${irrigation['moisture']}%'),
                metric('NITROGÊNIO', '${crop?['nitrogenPpm'] ?? '—'} ppm'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Dados fictícios da API; não há modelo de IA ou sensores físicos conectados.',
          style: TextStyle(fontSize: 12),
        ),
      ]),
      panel('HISTÓRICO DE TALHÃO', [
        Text(
          state['pest'] == true
              ? 'Foco detectado no cenário'
              : 'Sem foco aberto',
          style: CommandType.body(weight: 700),
        ),
        for (final h
            in (state['history'] as List)
                .where((h) => h['command'].toString().startsWith('pest.'))
                .take(3))
          Text('${h['label']} • ${h['at']}', style: CommandType.body(size: 12)),
      ]),
      panel('ALERTA DE SAÚDE • SIMULADO', [
        Text(
          state['pest'] == true ? 'Patógeno Detectado' : 'Inspeção de Campo',
          style: CommandType.display(size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          '${crop?['pathogen'] ?? 'Aguardando cenário'}'.toUpperCase(),
          style: CommandType.display(size: 21, color: CommandColors.primary),
        ),
        const SizedBox(height: 16),
        button('ATRIBUIR TAREFA', 'pest.detect', icon: Icons.assignment_add),
        button('CONCLUIR INSPEÇÃO', 'pest.resolve', icon: Icons.task_alt),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      switch (widget.section) {
        'mapa' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: map(),
        ),
        'rebanho' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: herd(),
        ),
        'scout' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: scout(),
        ),
        _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: dashboard(),
        ),
      },
      Text(
        'SIMULAÇÃO • dados compartilhados pela API • versão ${state['version']}',
        style: CommandType.label(size: 10),
      ),
    ],
  );
}

class ExpandedButton extends StatelessWidget {
  const ExpandedButton({required this.label, this.onPressed, super.key});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    child: Text(label, textAlign: TextAlign.center),
  );
}
