import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:aerogaze_mobile/core/sync/operations_api.dart';
import 'package:aerogaze_mobile/features/operations/scenario_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android executa falha, reparo e irrigação na API do cenário', (
    tester,
  ) async {
    const url = String.fromEnvironment('API_URL');
    expect({'http://127.0.0.1:3302', 'http://10.0.2.2:3302'}, contains(url));
    final api = OperationsApi(url);
    addTearDown(api.close);
    final session = await api.login(
      'gerente@demo.aerogaze',
      'demo-integration-2026',
    );
    final farm = (await api.list('/v1/farms', session)).first['id'] as String;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ScenarioView(
              session: session,
              farmId: farm,
              section: 'painel',
              offline: false,
              onChanged: () async {},
            ),
          ),
        ),
      ),
    );
    Future<void> press(String label) async {
      final finder = find.text(label);
      for (var i = 0; i < 180; i++) {
        await tester.pump(const Duration(milliseconds: 250));
        if (finder.evaluate().isNotEmpty) break;
      }
      expect(finder, findsOneWidget);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      for (var i = 0; i < 180; i++) {
        final button = tester.widget<FilledButton>(
          find.ancestor(of: finder, matching: find.byType(FilledButton)),
        );
        if (button.onPressed != null) break;
        await tester.pump(const Duration(milliseconds: 250));
      }
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> status(String value) async {
      for (var i = 0; i < 30; i++) {
        final state = await api.request(
          'GET',
          '/v1/demo/farms/$farm',
          token: session.token,
        );
        if (state['state']['irrigation']['status'] == value) return;
        await tester.pump(const Duration(milliseconds: 500));
      }
      fail('Status não confirmado na API: $value');
    }

    await press('Simular falha de irrigação');
    await status('falha');
    await press('Reparar irrigação');
    await status('parada');
    await press('Iniciar irrigação');
    await status('irrigando');
    final scenario = await api.request(
      'GET',
      '/v1/demo/farms/$farm',
      token: session.token,
    );
    expect(scenario['telemetry']['simulated'], true);
    expect((scenario['telemetry']['points'] as List).length, 14);
    final history = scenario['state']['history'] as List;
    expect(history.take(3).map((h) => h['command']), [
      'irrigation.start',
      'irrigation.repair',
      'irrigation.fail',
    ]);
    expect(history.first['eventId'], isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
