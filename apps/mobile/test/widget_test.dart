import 'package:aerogaze_mobile/features/map/map_page.dart';
import 'package:aerogaze_mobile/features/herd/herd_page.dart';
import 'package:aerogaze_mobile/features/scouting/scouting_page.dart';
import 'package:aerogaze_mobile/features/tasks/tasks_page.dart';
import 'package:aerogaze_mobile/app/aerogaze_app.dart';
import 'package:aerogaze_mobile/app/app_environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final name in ['Inter', 'SpaceGrotesk']) {
      await (FontLoader(
        name,
      )..addFont(rootBundle.load('assets/fonts/$name.ttf'))).load();
    }
  });
  test('native flavor selects the matching environment', () {
    expect(AppEnvironment.fromFlavor(null), AppEnvironment.dev);
    expect(AppEnvironment.fromFlavor('dev'), AppEnvironment.dev);
    expect(AppEnvironment.fromFlavor('prod'), AppEnvironment.prod);
    expect(() => AppEnvironment.fromFlavor('unknown'), throwsArgumentError);
  });
  testWidgets('all five native pages are reachable and identify demo data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const AeroGazeApp(showSplash: false, environment: AppEnvironment.prod),
    );
    await tester.pumpAndSettle();
    expect(find.text('AEROGAZE\nCOMMAND'), findsOneWidget);
    expect(find.text('DEMO'), findsOneWidget);
    for (final entry in {
      0: 'ÍNDICE DE SAÚDE',
      1: 'ALERTA CRÍTICO',
      2: 'ANÁLISE EM TEMPO REAL',
      3: 'Gestão de Rebanho',
      4: 'Central de Tarefas',
    }.entries) {
      await tester.tap(find.byKey(ValueKey('nav-${entry.key}')));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.text('SISTEMA\nATIVO'));
    await tester.pumpAndSettle();
    expect(find.text('DEMONSTRAÇÃO'), findsOneWidget);
    expect(find.textContaining('Ambiente prod.'), findsOneWidget);
  });
  testWidgets('tabs mount on first access and keep their state afterwards', (
    tester,
  ) async {
    await tester.pumpWidget(const AeroGazeApp(showSplash: false));
    await tester.pumpAndSettle();
    expect(find.byType(MapPage, skipOffstage: false), findsNothing);
    expect(find.byType(HerdPage, skipOffstage: false), findsNothing);
    expect(find.byType(ScoutingPage, skipOffstage: false), findsNothing);
    expect(find.byType(TasksPage, skipOffstage: false), findsNothing);
    await tester.tap(find.byKey(const ValueKey('nav-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filtrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-0')));
    await tester.pumpAndSettle();
    expect(find.byType(HerdPage, skipOffstage: false), findsOneWidget);
    expect(find.byType(MapPage, skipOffstage: false), findsNothing);
    await tester.tap(find.byKey(const ValueKey('nav-3')));
    await tester.pumpAndSettle();
    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Bovino #TX-042'), findsNothing);
  });

  testWidgets('task search filters native cards', (tester) async {
    await tester.pumpWidget(
      const AeroGazeApp(showSplash: false, initialTab: 4),
    );
    await tester.enterText(find.byKey(const ValueKey('task-search')), 'bovino');
    await tester.pumpAndSettle();
    expect(find.text('Manejo de Bovino #TX-012'), findsOneWidget);
    expect(find.text('Aplicação de Fungicida Setor B'), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('task-search')),
      'inexistente',
    );
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma tarefa encontrada.'), findsOneWidget);
  });
  testWidgets('herd filtering retains critical animal', (tester) async {
    await tester.pumpWidget(
      const AeroGazeApp(showSplash: false, initialTab: 3),
    );
    await tester.tap(find.text('Filtrar'));
    await tester.pumpAndSettle();
    expect(find.text('Bovino #TX-012'), findsOneWidget);
    expect(find.text('Bovino #TX-042'), findsNothing);
  });
  testWidgets('small screen and enlarged fonts keep layouts usable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const AeroGazeApp(showSplash: false));
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(ValueKey('nav-$i')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
