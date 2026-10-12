import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:aerogaze_mobile/core/database/field_database.dart';
import 'package:aerogaze_mobile/core/sync/operations_api.dart';
import 'package:aerogaze_mobile/core/sync/sync_runner.dart';

const session = ApiSession(
  baseUrl: 'https://api.invalid',
  token: 'test-only-token',
  userId: 'actor-a',
  organizationId: 'org-a',
  name: 'Teste',
  role: 'operador',
);
void main() {
  test(
    'file database preserves inspection, device and outbox across reopening; scopes remain isolated',
    () async {
      final directory = await Directory.systemTemp.createTemp('aerogaze-test-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/field.sqlite');
      final db = FieldDatabase(NativeDatabase(file));
      final scope = session.scope('farm-a');
      final device = await db.device(scope);
      final id = await db.save(scope, 'Revisar animal');
      final event = await db.event(id, scope);
      await db.close();
      final reopened = FieldDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      expect((await reopened.rows(scope)).single.id, id);
      expect(await reopened.event(id, scope), event);
      expect(await reopened.device(scope), device);
      expect(await reopened.rows(session.scope('outra-fazenda')), isEmpty);
      expect(await reopened.rows('outra-organizacao'), isEmpty);
    },
  );
  test('failure during outbox insertion rolls back inspection too', () async {
    final db = FieldDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.customStatement(
      "CREATE TRIGGER reject_outbox BEFORE INSERT ON outbox BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(db.save('scope', 'nota'), throwsA(anything));
    expect(await db.select(db.inspections).get(), isEmpty);
    expect(await db.rows('scope'), isEmpty);
  });
  test(
    'lost response retries identical UUID and payload; duplicate ACK is terminal',
    () async {
      final db = FieldDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final scope = session.scope('farm-a');
      final id = await db.save(scope, 'Nota manual');
      final bodies = <String>[];
      final serverIds = <String>{};
      final api = OperationsApi(
        session.baseUrl,
        client: MockClient((request) async {
          bodies.add(request.body);
          final event = (jsonDecode(request.body)['events'] as List).single;
          final isNew = serverIds.add(event['id']);
          if (isNew) throw http.ClientException('response lost after commit');
          return http.Response(
            jsonEncode({
              'acks': [
                {'id': id, 'status': 'duplicate'},
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(api.close);
      final runner = SyncRunner(db, api);
      await runner.run(session, 'farm-a');
      expect((await db.rows(scope)).single.status, 'retry');
      await runner.run(session, 'farm-a', manual: true);
      expect((await db.rows(scope)).single.status, 'synced');
      expect(serverIds, {id});
      expect(bodies[0], bodies[1]);
      await runner.run(session, 'farm-a', manual: true);
      expect(bodies.length, 2);
    },
  );
  for (final body in [
    {'acks': []},
    {
      'acks': [
        {'id': 'wrong', 'status': 'accepted'},
      ],
    },
    {
      'acks': [
        {'id': 'replace', 'status': 'unknown'},
      ],
    },
  ]) {
    test('malformed ACK keeps the event pending for retry: $body', () async {
      final db = FieldDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final scope = session.scope('farm-a');
      final id = await db.save(scope, 'Nota');
      final api = OperationsApi(
        session.baseUrl,
        client: MockClient(
          (_) async =>
              http.Response(jsonEncode(body).replaceAll('replace', id), 200),
        ),
      );
      addTearDown(api.close);
      await SyncRunner(db, api).run(session, 'farm-a');
      expect((await db.rows(scope)).single.status, 'retry');
      expect((await db.rows(scope)).single.ack, isNull);
    });
  }
  for (final status in [401, 403, 500]) {
    test(
      'HTTP $status preserves evidence and sets the correct retry policy',
      () async {
        final db = FieldDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final scope = session.scope('farm-a');
        final id = await db.save(scope, 'Nota');
        final api = OperationsApi(
          session.baseUrl,
          client: MockClient((_) async => http.Response('{}', status)),
        );
        addTearDown(api.close);
        await SyncRunner(db, api).run(session, 'farm-a');
        expect(
          (await db.rows(scope)).single.status,
          status == 401
              ? 'paused'
              : status == 403
              ? 'rejected'
              : 'retry',
        );
        expect((await db.event(id, scope))['id'], id);
      },
    );
  }
  test(
    'claim excludes concurrent workers and recovers only after expired lease',
    () async {
      final db = FieldDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final id = await db.save('scope', 'Nota');
      final now = DateTime.now();
      expect(await db.claim(id, 'scope', now), isTrue);
      expect(await db.claim(id, 'scope', now, manual: true), isFalse);
      expect(
        await db.claim(id, 'scope', now.add(const Duration(seconds: 91))),
        isTrue,
      );
    },
  );
  test('API URL rejects credentials and insecure remote HTTP', () {
    expect(
      () => OperationsApi('http://public.example'),
      throwsA(isA<ApiFailure>()),
    );
    expect(
      () => OperationsApi('https://user:password@api.example'),
      throwsA(isA<ApiFailure>()),
    );
    expect(
      OperationsApi.validateUrl('https://api.example/'),
      'https://api.example',
    );
  });
  test(
    'Retry-After blocks manual replay until the persisted deadline',
    () async {
      final db = FieldDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final scope = session.scope('farm-a');
      await db.save(scope, 'Nota');
      var attempts = 0;
      final api = OperationsApi(
        session.baseUrl,
        client: MockClient((_) async {
          attempts++;
          return http.Response('{}', 429, headers: {'retry-after': '1200'});
        }),
      );
      addTearDown(api.close);
      final runner = SyncRunner(db, api);
      await runner.run(session, 'farm-a');
      final row = (await db.rows(scope)).single;
      expect(row.httpStatus, 429);
      expect(
        row.nextAttempt,
        greaterThan(DateTime.now().millisecondsSinceEpoch + 1190000),
      );
      await runner.run(session, 'farm-a', manual: true);
      expect(attempts, 1);
    },
  );
  test(
    'explicit access revalidation preserves event and rejects other statuses and scopes',
    () async {
      final db = FieldDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final scope = session.scope('farm-a');
      final id = await db.save(scope, 'Original');
      final original = await db.event(id, scope);
      final row = (await db.rows(scope)).single;
      await db.failure(
        row,
        'Device not enrolled',
        rejected: true,
        httpStatus: 403,
      );
      expect(await db.retryAccessDenied(id, 'other-scope'), 0);
      expect(await db.retryAccessDenied(id, scope), 1);
      expect(await db.event(id, scope), original);
      expect((await db.rows(scope)).single.status, 'pending');
      await db.failure(
        (await db.rows(scope)).single,
        'Invalid payload',
        rejected: true,
        httpStatus: 422,
      );
      expect(await db.retryAccessDenied(id, scope), 0);
    },
  );
  test('schema upgrade preserves durable version-one evidence', () async {
    final dir = await Directory.systemTemp.createTemp('aerogaze-migration-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/field.sqlite');
    var db = FieldDatabase(NativeDatabase(file));
    final scope = session.scope('farm-a');
    final id = await db.save(scope, 'Before upgrade');
    final envelope = await db.event(id, scope);
    await db.customStatement('ALTER TABLE outbox DROP COLUMN http_status');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();
    db = FieldDatabase(NativeDatabase(file));
    addTearDown(db.close);
    expect(await db.event(id, scope), envelope);
    expect((await db.rows(scope)).single.id, id);
    expect((await db.rows(scope)).single.httpStatus, isNull);
    expect(
      await db
          .customSelect('PRAGMA user_version')
          .getSingle()
          .then((r) => r.read<int>('user_version')),
      2,
    );
  });
}
