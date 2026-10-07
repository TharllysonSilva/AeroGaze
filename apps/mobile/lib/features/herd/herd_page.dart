import 'package:flutter/material.dart';

import '../../app/design_system.dart';
import '../../core/demo/command_demo.dart';
import '../../core/design/reference_photo.dart';

class HerdPage extends StatefulWidget {
  const HerdPage({super.key});
  @override
  State<HerdPage> createState() => _HerdPageState();
}

class _HerdPageState extends State<HerdPage> {
  int _selected = 1;
  bool _criticalOnly = false;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('herd-scroll'),
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'MÓDULO DE VIGILÂNCIA BIOLÓGICA',
          style: CommandType.label(size: 11, color: CommandColors.primary),
        ),
        const SizedBox(height: 6),
        Text('Gestão de Rebanho', style: CommandType.display(size: 32)),
        const SizedBox(height: 16),
        Row(
          children: [
            CommandButton(
              label: _criticalOnly ? 'Todos' : 'Filtrar',
              fontSize: 12,
              height: 38,
              icon: Icons.filter_list,
              color: CommandColors.high,
              foreground: CommandColors.text,
              onPressed: () => setState(() => _criticalOnly = !_criticalOnly),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CommandButton(
                label: 'Sincronizar Novos Sensores',
                fontSize: 11,
                height: 38,
                icon: Icons.add,
                onPressed: () => showDemoDetail(
                  context,
                  'Sincronizar novos sensores',
                  'O pareamento e a leitura de sensores serão conectados à API. Os animais e sinais '
                      'exibidos nesta tela são exemplos da referência visual.',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        CommandPanel(
          padding: const EdgeInsets.all(16),
          accent: CommandColors.primary,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'UNIDADES DE MONITORAMENTO',
                      style: CommandType.label(size: 10, spacing: 0),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF273729),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'LIVE FEED',
                      style: CommandType.label(
                        size: 8,
                        color: CommandColors.primary,
                        spacing: .5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < CommandDemo.animals.length; i++)
                if (!_criticalOnly ||
                    CommandDemo.animals[i].status == 'Crítico') ...[
                  _AnimalRow(
                    animal: CommandDemo.animals[i],
                    selected: _selected == i,
                    onTap: () => setState(() => _selected = i),
                  ),
                  if (i != CommandDemo.animals.length - 1)
                    const SizedBox(height: 7),
                ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        CommandPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'OCUPAÇÃO POR STATUS',
                style: CommandType.label(size: 10, spacing: 0),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 70,
                      child: ColoredBox(
                        color: CommandColors.primary,
                        child: SizedBox(height: 8),
                      ),
                    ),
                    Expanded(
                      flex: 20,
                      child: ColoredBox(
                        color: CommandColors.blue,
                        child: SizedBox(height: 8),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: ColoredBox(
                        color: CommandColors.error,
                        child: SizedBox(height: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Legend('142 OK', CommandColors.primary),
                  _Legend('24 MON', CommandColors.blue),
                  _Legend('8 CRIT', CommandColors.error),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _AnimalProfile(animal: CommandDemo.animals[_selected]),
        const SizedBox(height: 24),
        CommandPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Análise Metabólica',
                          style: CommandType.body(size: 20, weight: 700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Previsão de anomalias baseada em telemetria 24h',
                          style: CommandType.body(
                            size: 12,
                            color: CommandColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CommandColors.high,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Últimas\n24h',
                      style: CommandType.body(size: 9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 220, child: _MetabolicChart()),
              const SizedBox(height: 36),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Risk(
                      'RISCO DE ACIDOSE',
                      'Baixo',
                      CommandColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _Risk(
                      'TAXA DE\nRUMINAÇÃO',
                      'Nominal',
                      CommandColors.text,
                    ),
                  ),
                  Expanded(
                    child: _Risk(
                      'ESTRESSE\nTÉRMICO',
                      'Moderado',
                      CommandColors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CommandButton(
          label: 'ADICIONAR TRATAMENTO',
          icon: Icons.medical_services,
          height: 56,
          onPressed: () => showDemoDetail(
            context,
            'Adicionar tratamento',
            'Animal selecionado: ${CommandDemo.animals[_selected].id}. '
                'O registro sanitário persistente e sua autoria serão implementados no fluxo de eventos offline.',
          ),
        ),
        const SizedBox(height: 16),
        CommandButton(
          label: 'MOVER DE PASTO',
          icon: Icons.move_up,
          height: 56,
          color: CommandColors.high,
          foreground: CommandColors.text,
          onPressed: () => showDemoDetail(
            context,
            'Mover de pasto',
            'Animal selecionado: ${CommandDemo.animals[_selected].id}. '
                'A movimentação precisa de origem, destino e evento rastreável; esta prévia não movimenta animais.',
          ),
        ),
      ],
    ),
  );
}

class _AnimalRow extends StatelessWidget {
  const _AnimalRow({
    required this.animal,
    required this.selected,
    required this.onTap,
  });
  final DemoAnimal animal;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final critical = animal.status == 'Crítico';
    return Material(
      color: critical
          ? const Color(0xFF2C1918)
          : selected
          ? const Color(0xFF202726)
          : CommandColors.high,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        key: ValueKey('animal-${animal.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: critical
                ? Border.all(color: CommandColors.error.withValues(alpha: .3))
                : null,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: ReferencePhoto(
                    asset: 'assets/reference/aerogaze_rebanho_pt.png',
                    region: animal.photo,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bovino #${animal.id}',
                      style: CommandType.body(
                        size: 13,
                        weight: 700,
                        color: critical
                            ? CommandColors.error
                            : CommandColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      animal.location,
                      style: CommandType.label(size: 8, spacing: .4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${critical ? '' : '● '}${animal.status}',
                      textAlign: TextAlign.right,
                      style: CommandType.body(
                        size: 8,
                        weight: 700,
                        color: animal.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      critical ? 'ALERTA' : 'v.8.2',
                      style: CommandType.label(
                        size: 8,
                        color: critical
                            ? CommandColors.error
                            : CommandColors.dim,
                        spacing: 0,
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
}

class _AnimalProfile extends StatelessWidget {
  const _AnimalProfile({required this.animal});
  final DemoAnimal animal;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: ColoredBox(
      color: CommandColors.panel,
      child: Column(
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ReferencePhoto(
                  asset: 'assets/reference/aerogaze_rebanho_pt.png',
                  region: Rect.fromLTWH(13, 596, 294, 44),
                  fit: BoxFit.fill,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, CommandColors.panel],
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: SizedBox(
                          width: 70,
                          height: 88,
                          child: ReferencePhoto(
                            asset: 'assets/reference/aerogaze_rebanho_pt.png',
                            region: animal.id == 'TX-089'
                                ? const Rect.fromLTWH(33, 664, 58, 73)
                                : animal.photo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    animal.id.replaceFirst('-', '-\n'),
                                    style: CommandType.display(size: 28),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: CommandColors.blue.withValues(
                                        alpha: .15,
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      animal.status.toUpperCase(),
                                      style: CommandType.label(
                                        size: 8,
                                        color: animal.color,
                                        spacing: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'IDENTIFICADOR BIOMÉTRICO:\n8829-AFZ-09',
                              style: CommandType.label(size: 11, spacing: .6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: _Biometric(
                        'FREQ. CARDÍACA',
                        '72',
                        'bpm',
                        Icons.favorite,
                        CommandColors.blue,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _Biometric(
                        'TEMPERATURA',
                        '38.4',
                        '°C',
                        Icons.device_thermostat,
                        CommandColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(
                      child: _Biometric(
                        'PASTEJO (HOJE)',
                        '6.8',
                        'horas',
                        Icons.timer,
                        CommandColors.primary,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _Biometric(
                        'PESO EST.',
                        '542',
                        'kg',
                        Icons.monitor_weight,
                        CommandColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Biometric extends StatelessWidget {
  const _Biometric(this.title, this.value, this.unit, this.icon, this.color);
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF242926),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: CommandType.display(size: 8, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 3,
          children: [
            Text(value, style: CommandType.display(size: 25)),
            Text(
              unit,
              style: CommandType.body(size: 10, color: CommandColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: color),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: CommandType.label(
          size: 9,
          color: CommandColors.text,
          spacing: .3,
        ),
      ),
    ],
  );
}

class _Risk extends StatelessWidget {
  const _Risk(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: CommandType.label(size: 8, spacing: 0)),
      const SizedBox(height: 8),
      Text(value, style: CommandType.body(size: 14, color: color, weight: 700)),
    ],
  );
}

class _MetabolicChart extends StatelessWidget {
  const _MetabolicChart();
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned.fill(child: CustomPaint(painter: _ChartPainter())),
      Positioned(
        left: 128,
        top: 12,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CommandColors.high,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PICO DE ATIVIDADE',
                style: CommandType.display(size: 8, color: CommandColors.blue),
              ),
              const SizedBox(height: 4),
              Text(
                '+12% vs Média',
                style: CommandType.label(size: 8, spacing: 0),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ChartPainter extends CustomPainter {
  const _ChartPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * .56)
      ..cubicTo(w * .2, h * .55, w * .22, h * .38, w * .38, h * .48)
      ..cubicTo(w * .5, h * .63, w * .55, h * .5, w * .62, h * .4)
      ..cubicTo(w * .77, h * .12, w * .78, h * .87, w * .93, h * .68)
      ..quadraticBezierTo(w * .97, h * .61, w, h * .53);
    final fill = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x226BCA65), Color(0x0020261F)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = CommandColors.primary
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      Offset(w * .62, h * .4),
      2.5,
      Paint()..color = CommandColors.primary,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) => false;
}
