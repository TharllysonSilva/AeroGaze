import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:aerogaze_mobile/app/aerogaze_app.dart';
import 'package:aerogaze_mobile/core/sync/operations_api.dart';
import 'package:aerogaze_mobile/features/auth/auth_widgets.dart';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 180; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Expected widget was not displayed: $finder');
}

Future<void> tap(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await waitFor(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native session, offline SQLite reopening, HTTP ACK, task and public mock receipt',
    (tester) async {
      const url = String.fromEnvironment('API_URL');
      expect({
        'http://10.0.2.2:3302',
        'http://127.0.0.1:3302',
      }, contains(url)); // Local disposable backend only.
      final api = OperationsApi(url);
      addTearDown(api.close);
      final session = await api.login(
        'gerente@demo.aerogaze',
        'demo-integration-2026',
      );
      final farms = await api.list('/v1/farms', session);
      final farm = farms.first['id'];
      await tester.pumpWidget(const AeroGazeApp(showSplash: false));
      await tester.pumpAndSettle();
      if (find.byKey(const ValueKey('login-operator')).evaluate().isNotEmpty) {
        await tester.enterText(
          find.byKey(const ValueKey('login-operator')),
          'gerente@demo.aerogaze',
        );
        await tester.enterText(
          find.byKey(const ValueKey('login-password')),
          'demo-integration-2026',
        );
        await tap(tester, 'login-submit');
      }
      await tap(tester, 'tab-map');
      await waitFor(
        tester,
        find.text('POLÍGONOS CADASTRADOS • POSIÇÕES FICTÍCIAS'),
      );
      await tap(tester, 'tab-herd');
      await tap(tester, 'tab-tasks');
      await tap(tester, 'tab-scout');
      await waitFor(tester, find.byKey(const ValueKey('operation-notes')));
      final uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f-]{27}$');
      final previousIds = tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .map((w) => w.data ?? '')
          .where(uuidPattern.hasMatch)
          .toSet();
      await tap(tester, 'operation-offline');
      final notes =
          'Inspeção Android sem inferência ${DateTime.now().millisecondsSinceEpoch}';
      await tester.ensureVisible(find.byKey(const ValueKey('operation-notes')));
      await tester.enterText(
        find.byKey(const ValueKey('operation-notes')),
        notes,
      );
      await tap(tester, 'operation-save');
      await waitFor(tester, find.text('Pendente de envio'));
      final newEventFinder = find.byWidgetPredicate(
        (w) =>
            w is SelectableText &&
            uuidPattern.hasMatch(w.data ?? '') &&
            !previousIds.contains(w.data),
      );
      await waitFor(tester, newEventFinder);
      final eventId = tester.widget<SelectableText>(newEventFinder).data!;
      var events = await api.list('/v1/events?farmId=$farm', session);
      expect(events.where((e) => e['payload']['notes'] == notes), isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.pumpWidget(const AeroGazeApp(showSplash: false));
      await tap(tester, 'tab-scout');
      await waitFor(tester, find.text('Pendente de envio'));
      await tap(tester, 'operation-sync');
      for (var i = 0; i < 30; i++) {
        events = await api.list('/v1/events?farmId=$farm', session);
        if (events.any((e) => e['id'] == eventId)) break;
        await tester.pump(const Duration(seconds: 2));
      }
      expect(events.where((e) => e['id'] == eventId).length, 1);
      await waitFor(
        tester,
        find.descendant(
          of: find.ancestor(
            of: find.text(eventId),
            matching: find.byType(AuthCard),
          ),
          matching: find.text('Ingestão confirmada • accepted'),
        ),
      );
      final event = events.singleWhere((e) => e['id'] == eventId);
      expect(event['payload']['notes'], notes);
      expect(event['payload']['captureMode'], 'manual');
      expect(event['payload']['ai'], isNull);
      final tasks = await api.list('/v1/tasks?farmId=$farm', session);
      expect(tasks.where((t) => t['source_event_id'] == event['id']).length, 1);
      Map<String, dynamic>? receipt;
      for (var i = 0; i < 20; i++) {
        receipt =
            (await api.request(
                  'GET',
                  '/v1/sync/events/${event['id']}/receipt',
                  token: session.token,
                ))
                as Map<String, dynamic>;
        if (receipt['batch']?['status'] == 'ancorado') break;
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      expect(receipt!['tasks'].length, 1);
      expect(receipt['batch']['status'], 'ancorado');
      final proof = await api.request(
        'GET',
        '/v1/verify/${receipt['batch']['id']}',
      );
      expect(proof['valid'], isTrue);
      expect(proof['anchor']['mode'], 'mock');
      expect(
        proof['note'],
        contains('SIMULADA'),
      ); // Never present this local test as blockchain proof.
      await tap(tester, 'operation-sync');
      final after = await api.list('/v1/tasks?farmId=$farm', session);
      expect(after.where((t) => t['source_event_id'] == event['id']).length, 1);
      final task = after.singleWhere(
        (t) => t['source_event_id'] == event['id'],
      );
      await tap(tester, 'tab-tasks');
      for (final step in [
        ('task-start:', 'em_progresso'),
        ('task-complete:', 'concluida'),
      ]) {
        final key = ValueKey('${step.$1}${task['id']}');
        await waitFor(
          tester,
          find.byWidgetPredicate(
            (w) => w is TextButton && w.key == key && w.onPressed != null,
          ),
        );
        await tap(tester, key.value);
        var confirmed = false;
        for (var i = 0; i < 30; i++) {
          final list = await api.list('/v1/tasks?farmId=$farm', session);
          confirmed = list.any(
            (t) => t['id'] == task['id'] && t['status'] == step.$2,
          );
          if (confirmed) break;
          await tester.pump(const Duration(seconds: 1));
        }
        expect(confirmed, isTrue);
      }
      final afterTask = await api.request(
        'GET',
        '/v1/verify/${receipt['batch']['id']}',
      );
      expect(afterTask['valid'], isTrue);
      expect(afterTask['merkleRoot'], proof['merkleRoot']);
      final extraNotes =
          'Nova revisão pelo botão de tarefas ${DateTime.now().millisecondsSinceEpoch}';
      await tester.ensureVisible(find.byIcon(Icons.add_circle));
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('new-review-notes')),
        extraNotes,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();
      Map<String, dynamic>? extraEvent;
      for (var i = 0; i < 30; i++) {
        final current = await api.list('/v1/events?farmId=$farm', session);
        extraEvent = current
            .where((e) => e['payload']['notes'] == extraNotes)
            .firstOrNull;
        if (extraEvent != null) break;
        await tester.pump(const Duration(seconds: 1));
      }
      expect(extraEvent, isNotNull);
      final extraTasks = await api.list('/v1/tasks?farmId=$farm', session);
      expect(
        extraTasks
            .where((t) => t['source_event_id'] == extraEvent!['id'])
            .length,
        1,
      );

      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
