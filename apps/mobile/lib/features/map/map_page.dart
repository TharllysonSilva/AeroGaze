import 'package:flutter/material.dart';

import '../../app/design_system.dart';
import '../../core/design/reference_photo.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _layer = 0;
  double _zoom = 1;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: Transform.scale(
            scale: _zoom,
            child: const ReferencePhoto(
              asset: 'assets/reference/aerogaze_mapa_pt.png',
              region: Rect.fromLTWH(570, 116, 136, 1330),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 32,
          width: 142,
          child: CommandPanel(
            padding: const EdgeInsets.all(5),
            color: const Color(0xEE1A1D1B),
            child: Column(
              children: [
                for (var i = 0; i < 3; i++)
                  Material(
                    color: _layer == i
                        ? CommandColors.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    child: InkWell(
                      key: ValueKey('map-layer-$i'),
                      onTap: () => setState(() => _layer = i),
                      borderRadius: BorderRadius.circular(7),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              [Icons.grass, Icons.pets, Icons.sensors][i],
                              size: 20,
                              color: _layer == i
                                  ? const Color(0xFF002203)
                                  : CommandColors.muted,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ['CULTURAS', 'GADO', 'SENSORES'][i],
                                style: CommandType.display(
                                  size: 12,
                                  spacing: 1,
                                  color: _layer == i
                                      ? const Color(0xFF002203)
                                      : CommandColors.muted,
                                ),
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
        ),
        Positioned(
          left: 24,
          top: 165,
          width: 142,
          child: CommandPanel(
            padding: const EdgeInsets.all(8),
            color: const Color(0xF51A1D1B),
            child: Column(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: 'Aproximar mapa',
                  onPressed: () =>
                      setState(() => _zoom = (_zoom + .15).clamp(1, 2)),
                  icon: const Icon(
                    Icons.add,
                    color: CommandColors.muted,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: 'Afastar mapa',
                  onPressed: () =>
                      setState(() => _zoom = (_zoom - .15).clamp(1, 2)),
                  icon: const Icon(
                    Icons.remove,
                    color: CommandColors.muted,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  tooltip: 'Alternar camada',
                  onPressed: () => setState(() => _layer = (_layer + 1) % 3),
                  icon: const Icon(
                    Icons.layers,
                    color: CommandColors.muted,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: constraints.maxWidth * .7,
          top: constraints.maxHeight * .17,
          child: _marker(
            _layer == 1 ? Icons.pets : Icons.sensors,
            label: _layer == 2 ? 'NÓ-22' : null,
          ),
        ),
        Positioned(
          left: constraints.maxWidth * .26,
          top: constraints.maxHeight * .64,
          child: _marker(Icons.sensors),
        ),
        if (_layer != 2)
          Positioned(
            left: constraints.maxWidth * .44,
            top: constraints.maxHeight * .38,
            child: _marker(Icons.pets, label: 'BR-042', animal: true),
          ),
        Positioned(
          left: 24,
          bottom: 26,
          width: constraints.maxWidth - 102,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight * .52),
            child: SingleChildScrollView(
              child: CommandPanel(
                accent: CommandColors.error,
                color: const Color(0xF5290705),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.error,
                          size: 14,
                          color: CommandColors.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ALERTA CRÍTICO',
                            style: CommandType.display(
                              size: 11,
                              color: CommandColors.error,
                              spacing: .6,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.warning,
                          color: Color(0xFF5A2520),
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'FALHA DE IRRIGAÇÃO - SETOR 7-B',
                      style: CommandType.display(size: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pressão hidráulica abaixo de 1.2 bar detectada no bico injetor primário. '
                      'Risco de estresse hídrico.',
                      style: CommandType.body(
                        size: 13,
                        color: CommandColors.muted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: CommandButton(
                            label: 'DESLIGAR',
                            color: CommandColors.error,
                            fontSize: 10,
                            height: 30,
                            onPressed: () => showDemoDetail(
                              context,
                              'Desligar irrigação',
                              'Este controle ilustra uma ação de contingência. '
                                  'Nenhum equipamento será desligado.',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CommandButton(
                            label: 'DETALHES',
                            color: const Color(0xFF3B1714),
                            foreground: CommandColors.error,
                            fontSize: 10,
                            height: 30,
                            onPressed: () => showDemoDetail(
                              context,
                              'Falha de irrigação — Setor 7-B',
                              'Pressão de referência: abaixo de 1.2 bar. Verificar o bico injetor primário '
                                  'e a linha de alimentação antes de qualquer intervenção.',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _marker(IconData icon, {String? label, bool animal = false}) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: animal ? 32 : 9,
        height: animal ? 44 : 9,
        decoration: BoxDecoration(
          color: animal ? const Color(0x773F6932) : CommandColors.blue,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: animal ? const Color(0xFF7B9954) : CommandColors.lowest,
            width: 1.3,
          ),
        ),
        child: animal
            ? Icon(icon, size: 19, color: CommandColors.primaryContainer)
            : null,
      ),
      if (label != null)
        Text(
          label,
          style: CommandType.display(size: 10, color: CommandColors.primary),
        ),
    ],
  );
}
