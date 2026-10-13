import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aerogaze_mobile/app/aerogaze_app.dart';
import 'package:aerogaze_mobile/app/app_environment.dart';
import 'package:aerogaze_mobile/features/operations/scenario_presentation.dart';

final scenario = <String, dynamic>{
  'state': {
    'version': 8,
    'irrigation': {
      'status': 'falha',
      'moisture': 42.4,
      'pressure': 0.7,
      'flow': 0,
    },
    'drone': {'status': 'base', 'battery': 94, 'signal': 98},
    'pest': true,
    'support': 'pronto',
    'stock': {'feedKg': 840, 'vaccines': 24},
    'history': [
      {
        'at': '2026-10-13T01:00:00Z',
        'label': 'Falha de irrigação detectada',
        'eventId': 'event-test',
      },
    ],
    'animals': List.generate(
      12,
      (i) => {
        'id': 'BR-${(i + 1).toString().padLeft(3, '0')}',
        'name': 'Bovino ${i + 1}',
        'status': i == 2 ? 'atencao' : 'saudavel',
        'plot': i % 3,
        'vaccinated': false,
        'battery': 90,
        'temperature': 38.4,
        'heartRate': 72,
      },
    ),
  },
  'plots': [
    {
      'boundary': {
        'coordinates': [
          [
            [-55.824, -12.646],
            [-55.822, -12.646],
            [-55.822, -12.644],
            [-55.824, -12.644],
            [-55.824, -12.646],
          ],
        ],
      },
    },
  ],
  'telemetry': {
    'crop': {
      'simulated': true,
      'chlorophyll': .82,
      'confidence': 92,
      'nitrogenPpm': 210,
      'pathogen': 'Mancha de folha',
    },
    'animalStats': List.generate(
      12,
      (i) => {
        'id': 'BR-${(i + 1).toString().padLeft(3, '0')}',
        'weightKg': 510 + i * 8,
        'pastureHours': 6.8,
        'acidosisRisk': 'Baixo',
        'rumination': 'Nominal',
        'thermalStress': 'Moderado',
        'activity': List.generate(12, (n) => {'value': 45 + n % 4}),
      },
    ),
    'points': [
      {
        'kind': 'animal',
        'label': 'BR-003',
        'status': 'atencao',
        'lat': -12.645,
        'lon': -55.823,
      },
    ],
    'series': List.generate(12, (i) => {'moisture': 42 + i % 4}),
  },
};
void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    for (final name in ['Inter', 'SpaceGrotesk']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  Future<void> render(
    WidgetTester t,
    String section, {
    bool canAct = true,
    void Function(String, [String?])? action,
  }) async {
    t.view.physicalSize = const Size(360, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Inter',
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFA3F69B),
            surface: Color(0xFF1A1D1B),
            onSurface: Color(0xFFE2E2E2),
          ),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ScenarioPresentation(
              data: scenario,
              section: section,
              canAct: canAct,
              onAction: action ?? (c, [a]) {},
              onRefresh: () {},
              onSolana: (e, p) {},
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('Falha envia comando e auditor tem controles bloqueados', (
    t,
  ) async {
    String? command;
    await render(t, 'painel', action: (c, [a]) => command = c);
    final button = find.text('Simular falha de irrigação');
    await t.ensureVisible(button);
    await t.tap(button);
    expect(command, 'irrigation.fail');
    await render(t, 'painel', canAct: false);
    final control = t.widget<FilledButton>(
      find.ancestor(of: button, matching: find.byType(FilledButton)),
    );
    expect(control.onPressed, isNull);
    expect(t.takeException(), isNull);
  });
  testWidgets('Atendimento usa animal selecionado e filtro é funcional', (
    t,
  ) async {
    String? target;
    await render(t, 'rebanho', action: (c, [a]) => target = a);
    final animal = find.text('Bovino #BR-001');
    await t.ensureVisible(animal);
    await t.tap(animal);
    await t.pump();
    final treat = find.text('ADICIONAR TRATAMENTO');
    await t.ensureVisible(treat);
    await t.tap(treat);
    expect(target, 'BR-001');
    final filter = find.text('Filtrar atenção');
    await t.ensureVisible(filter);
    await t.tap(filter);
    await t.pump();
    expect(find.text('Bovino #BR-001'), findsNothing);
    expect(find.text('Bovino #BR-003'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  for (final section in ['painel', 'mapa', 'scout', 'rebanho']) {
    testWidgets('$section sem overflow em tela pequena e fonte ampliada', (
      t,
    ) async {
      await render(t, section);
      final key = GlobalKey();
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Inter',
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFA3F69B),
              surface: Color(0xFF1A1D1B),
              onSurface: Color(0xFFE2E2E2),
            ),
          ),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: RepaintBoundary(
              key: key,
              child: Scaffold(
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ScenarioPresentation(
                    data: scenario,
                    section: section,
                    canAct: true,
                    onAction: (c, [a]) {},
                    onRefresh: () {},
                    onSolana: (e, p) {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      if (const bool.fromEnvironment('CAPTURE_SCENARIO')) {
        // Rendered Flutter artifact, not a screenshot of an interactive device.
        t.view.physicalSize = const Size(390, 2200);
        await t.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Inter',
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFA3F69B),
                surface: Color(0xFF1A1D1B),
                onSurface: Color(0xFFE2E2E2),
              ),
            ),
            home: RepaintBoundary(
              key: key,
              child: Scaffold(
                backgroundColor: const Color(0xFF121414),
                body: Column(
                  children: [
                    const CommandHeader(
                      environment: AppEnvironment.dev,
                      connected: true,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: ScenarioPresentation(
                          data: scenario,
                          section: section,
                          canAct: true,
                          onAction: (c, [a]) {},
                          onRefresh: () {},
                          onSolana: (e, p) {},
                        ),
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: CommandNavigation(
                  index: [
                    'painel',
                    'mapa',
                    'scout',
                    'rebanho',
                  ].indexOf(section),
                  onSelect: (_) {},
                ),
              ),
            ),
          ),
        );
        await t.runAsync(() async {
          for (final a in [
            'aerogaze_mapa_pt.png',
            'aerogaze_rebanho_pt.png',
            'aerogaze_dashboard_pt.png',
          ]) {
            await precacheImage(
              AssetImage('assets/reference/$a'),
              key.currentContext!,
            );
          }
        });
        await t.pumpAndSettle();
        await t.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final f = File('.tools/previews/connected-$section.png');
          await f.parent.create(recursive: true);
          await f.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }
}
