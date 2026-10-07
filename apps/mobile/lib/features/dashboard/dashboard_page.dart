import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/design_system.dart';
import '../../core/demo/command_demo.dart';
import '../../core/design/reference_photo.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.onOpenHerd,
    required this.onOpenMap,
    super.key,
  });
  final VoidCallback onOpenHerd;
  final VoidCallback onOpenMap;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('dashboard-scroll'),
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Status da Fazenda: Estável sob vigilância orbital.',
          style: CommandType.body(size: 14, color: CommandColors.muted),
        ),
        const SizedBox(height: 40),
        const _HealthCard(),
        const SizedBox(height: 24),
        CommandPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ALERTAS PREDITIVOS', style: CommandType.label()),
                  const Icon(
                    Icons.warning_amber,
                    color: CommandColors.error,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _AlertTile(
                icon: Icons.pest_control,
                title: 'Risco de Pragas Detectado',
                description: 'Sectores 4B-7A • Probabilidade 88%',
                color: CommandColors.error,
                background: const Color(0xFF332B2A),
                onTap: () => showDemoDetail(
                  context,
                  'Risco de Pragas Detectado',
                  'Alerta ilustrativo dos setores 4B-7A. '
                      'Probabilidade apresentada na referência: 88%.',
                ),
              ),
              const SizedBox(height: 16),
              _AlertTile(
                icon: Icons.water_drop_outlined,
                title: 'Previsão de Irrigação',
                description: 'Otimização recomendada para 04:00 AM',
                color: CommandColors.cyan,
                background: const Color(0xFF153235),
                onTap: () => showDemoDetail(
                  context,
                  'Previsão de Irrigação',
                  'Janela ilustrativa de irrigação às 04:00 AM. '
                      'Nenhum sistema de irrigação está conectado.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CommandPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('RESUMO DO REBANHO', style: CommandType.label()),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: _Metric(
                      label: 'SAUDÁVEIS',
                      value: '${CommandDemo.healthyAnimals}',
                      color: CommandColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: _Metric(
                      label: 'ANOMALIAS',
                      value: CommandDemo.anomalies,
                      color: CommandColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Material(
                color: CommandColors.high,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onOpenHerd,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 84,
                          height: 32,
                          child: Stack(
                            children: [
                              for (var i = 0; i < 3; i++)
                                Positioned(
                                  left: i * 24,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF343837),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: CommandColors.lowest,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: CustomPaint(
                                        size: Size(14, 14),
                                        painter: _CowGlyph(),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Ver Detalhes',
                          style: CommandType.body(
                            size: 11,
                            color: CommandColors.primary,
                            weight: 600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(color: CommandColors.lowest),
                const Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  height: 212,
                  child: ReferencePhoto(
                    asset: 'assets/reference/aerogaze_dashboard_pt.png',
                    region: Rect.fromLTWH(16, 1100, 358, 160),
                    fit: BoxFit.fill,
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [.3, 1],
                      colors: [Colors.transparent, CommandColors.lowest],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _HudChip('LIVE TELEMETRY', color: CommandColors.primary),
                      _HudChip(
                        'LAT: ${CommandDemo.latitude} LON: ${CommandDemo.longitude}',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monitoramento em Tempo Real',
                              style: CommandType.body(size: 15, weight: 700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AeroScout Drone-4 está em rota de patrulha',
                              style: CommandType.body(
                                size: 12,
                                color: CommandColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 109,
                        child: CommandButton(
                          label: 'EXPANDIR\nMAPA',
                          fontSize: 11,
                          height: 48,
                          onPressed: onOpenMap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        CommandPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ATIVIDADES RECENTES', style: CommandType.label()),
              const SizedBox(height: 24),
              const _Activity(
                'Scout-4 Missão Concluída',
                'Mapeamento de biomassa finalizado com sucesso.',
                'HÁ 12 MINUTOS',
                CommandColors.primary,
              ),
              const _Activity(
                'Calibração de Solo Nó-22',
                'Sensores de umidade recalibrados para o Setor Sul.',
                'HÁ 45 MINUTOS',
                CommandColors.cyan,
              ),
              const _Activity(
                'Backup de Dados Orbitais',
                'Sincronização completa com o servidor central.',
                'HÁ 2 HORAS',
                CommandColors.dim,
                last: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HealthCard extends StatelessWidget {
  const _HealthCard();
  @override
  Widget build(BuildContext context) => CommandPanel(
    child: Column(
      children: [
        Text('ÍNDICE DE SAÚDE', style: CommandType.label(spacing: 2)),
        const SizedBox(height: 28),
        SizedBox(
          width: 188,
          height: 188,
          child: CustomPaint(
            painter: _HealthRing(),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${CommandDemo.healthIndex}',
                    style: CommandType.display(
                      size: 48,
                      color: CommandColors.primary,
                    ),
                  ),
                  Text(
                    '/100',
                    style: CommandType.body(
                      size: 16,
                      color: CommandColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: CommandColors.lowest,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.trending_up,
                size: 16,
                color: CommandColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '+2.4% vs semana anterior',
                  style: CommandType.body(
                    size: 12,
                    color: CommandColors.primary,
                    weight: 600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HealthRing extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawOval(rect, paint..color = const Color(0xFF313632));
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * CommandDemo.healthIndex / 100,
      false,
      paint..color = CommandColors.primary,
    );
  }

  @override
  bool shouldRepaint(_HealthRing oldDelegate) => false;
}

class _CowGlyph extends CustomPainter {
  const _CowGlyph();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE2E2E2);
    canvas.drawOval(const Rect.fromLTWH(1, 1, 4, 5), paint);
    canvas.drawOval(const Rect.fromLTWH(9, 1, 4, 5), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4, 2, 6, 10),
        const Radius.circular(3),
      ),
      paint,
    );
    canvas.drawOval(
      const Rect.fromLTWH(3, 9, 8, 4),
      paint..color = CommandColors.error,
    );
    canvas.drawCircle(
      const Offset(5.5, 6),
      .7,
      paint..color = CommandColors.lowest,
    );
    canvas.drawCircle(const Offset(8.5, 6), .7, paint);
  }

  @override
  bool shouldRepaint(_CowGlyph oldDelegate) => false;
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.background,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: background,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CommandType.body(size: 13, weight: 700)),
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
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CommandColors.lowest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CommandType.label(size: 9, spacing: 0)),
        const SizedBox(height: 4),
        Text(value, style: CommandType.display(size: 30, color: color)),
      ],
    ),
  );
}

class _HudChip extends StatelessWidget {
  const _HudChip(this.label, {this.color = CommandColors.text});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: color == CommandColors.primary
          ? const Color(0xFF2C412A)
          : CommandColors.lowest,
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(label, style: CommandType.display(size: 9, color: color)),
  );
}

class _Activity extends StatelessWidget {
  const _Activity(
    this.title,
    this.description,
    this.time,
    this.color, {
    this.last = false,
  });
  final String title;
  final String description;
  final String time;
  final Color color;
  final bool last;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 24,
          child: Stack(
            children: [
              if (!last)
                Positioned(
                  left: 3,
                  top: 12,
                  bottom: 0,
                  child: Container(width: 1, color: CommandColors.high),
                ),
              Positioned(
                top: 6,
                left: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CommandType.body(size: 13, weight: 700)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: CommandType.body(size: 12, color: CommandColors.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: CommandType.display(
                    size: 9,
                    color: const Color(0xFF689A5C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
