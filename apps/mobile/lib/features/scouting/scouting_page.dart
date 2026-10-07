import 'package:flutter/material.dart';

import '../../app/design_system.dart';
import '../../core/demo/command_demo.dart';
import '../../core/design/reference_photo.dart';

class ScoutingPage extends StatelessWidget {
  const ScoutingPage({required this.onOpenTasks, super.key});
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(
        child: ReferencePhoto(
          asset: 'assets/reference/aerogaze_scouting_pt.png',
          region: Rect.fromLTWH(0, 98, 34, 1370),
          fit: BoxFit.fill,
        ),
      ),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x334D6948), Color(0x66081004)],
            ),
          ),
        ),
      ),
      SingleChildScrollView(
        key: const PageStorageKey('scouting-scroll'),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 84),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CommandPanel(
              accent: CommandColors.primary,
              color: const Color(0xF21B231B),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ANÁLISE EM TEMPO REAL',
                    style: CommandType.label(
                      size: 11,
                      color: CommandColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ÍNDICE DE CLOROFILA',
                    style: CommandType.body(
                      size: 10,
                      color: CommandColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        CommandDemo.chlorophyll,
                        style: CommandType.display(size: 26),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NM',
                        style: CommandType.display(
                          size: 11,
                          color: CommandColors.muted,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 96,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: const LinearProgressIndicator(
                            value: .82,
                            minHeight: 4,
                            color: CommandColors.primary,
                            backgroundColor: CommandColors.high,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'CONFIANÇA',
                    style: CommandType.body(
                      size: 10,
                      color: CommandColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        CommandDemo.confidence,
                        style: CommandType.display(size: 26),
                      ),
                      Text('%', style: CommandType.display(size: 12)),
                      const Spacer(),
                      const Icon(
                        Icons.verified,
                        size: 25,
                        color: CommandColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  CommandPanel(
                    color: CommandColors.high,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.sensors,
                              size: 15,
                              color: CommandColors.blue,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SENSORES DE SOLO',
                              style: CommandType.body(
                                size: 10,
                                color: CommandColors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _Reading('UMIDADE', '42.4%')),
                            Expanded(child: _Reading('NITROGÊNIO', '210 ppm')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CommandPanel(
              color: const Color(0xF21B231B),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HISTÓRICO DE TALHÃO',
                    style: CommandType.label(size: 11),
                  ),
                  const SizedBox(height: 16),
                  const _History(
                    'Focos Detectados (24h)',
                    'Setor Norte B-12',
                    CommandColors.error,
                  ),
                  const SizedBox(height: 12),
                  const _History(
                    'Tratamento Aplicado',
                    'Há 3 dias',
                    Color(0xFF79AA69),
                    muted: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CommandPanel(
              color: const Color(0xF2272D28),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF492522),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning,
                            color: CommandColors.error,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ALERTA DE SAÚDE',
                            style: CommandType.display(
                              size: 10,
                              color: CommandColors.error,
                              spacing: .7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Patógeno Detectado',
                    textAlign: TextAlign.center,
                    style: CommandType.display(size: 26),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'MANCHA DE FOLHA',
                    textAlign: TextAlign.center,
                    style: CommandType.display(
                      size: 18,
                      color: CommandColors.primary,
                      weight: 400,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CommandButton(
                    label: 'SALVAR OBSERVAÇÃO',
                    icon: Icons.save,
                    color: CommandColors.primary,
                    fontSize: 15,
                    height: 56,
                    onPressed: () => showDemoDetail(
                      context,
                      'Salvar observação',
                      'A interface reproduz o resultado visual de referência. '
                          'Captura por câmera, inferência TFLite e persistência offline ainda serão integradas. '
                          'Esta classificação não é um diagnóstico realizado pelo aparelho.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommandButton(
                    label: 'ATRIBUIR TAREFA',
                    icon: Icons.assignment_add,
                    color: const Color(0xFF333735),
                    foreground: CommandColors.text,
                    fontSize: 15,
                    height: 56,
                    onPressed: onOpenTasks,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Reading extends StatelessWidget {
  const _Reading(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: CommandType.body(size: 10, color: CommandColors.muted),
      ),
      const SizedBox(height: 4),
      Text(value, style: CommandType.display(size: 16)),
    ],
  );
}

class _History extends StatelessWidget {
  const _History(this.title, this.subtitle, this.color, {this.muted = false});
  final String title;
  final String subtitle;
  final Color color;
  final bool muted;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        Container(
          width: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CommandType.body(
                  size: 13,
                  color: muted ? CommandColors.dim : CommandColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: CommandType.body(
                  size: 11,
                  color: muted ? CommandColors.dim : CommandColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
