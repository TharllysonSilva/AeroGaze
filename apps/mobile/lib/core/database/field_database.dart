import 'dart:math';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';
part 'field_database.g.dart';

class Inspections extends Table {
  TextColumn get id => text()();
  TextColumn get scope => text()();
  TextColumn get envelope => text()();
  @override
  Set<Column> get primaryKey => {id};
}

class Outbox extends Table {
  TextColumn get id => text().references(Inspections, #id)();
  TextColumn get scope => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get nextAttempt => integer().withDefault(const Constant(0))();
  IntColumn get leaseUntil => integer().nullable()();
  TextColumn get error => text().nullable()();
  IntColumn get httpStatus => integer().nullable()();
  TextColumn get ack => text().nullable()();
  @override
  Set<Column> get primaryKey => {id};
}

class Devices extends Table {
  TextColumn get scope => text()();
  TextColumn get deviceId => text()();
  @override
  Set<Column> get primaryKey => {scope};
}

@DriftDatabase(tables: [Inspections, Outbox, Devices])
class FieldDatabase extends _$FieldDatabase {
  FieldDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'aerogaze_field'));
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(outbox, outbox.httpStatus);
      }
    },
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
  Future<String> device(String scope) => transaction(() async {
    final existing = await (select(
      devices,
    )..where((t) => t.scope.equals(scope))).getSingleOrNull();
    if (existing != null) return existing.deviceId;
    final id = 'flutter-${const Uuid().v4()}';
    await into(
      devices,
    ).insert(DevicesCompanion.insert(scope: scope, deviceId: id));
    return id;
  });
  Future<String> save(String scope, String notes) => transaction(() async {
    final id = const Uuid().v4();
    final envelope = jsonEncode({
      'id': id,
      'type': 'inspection.recorded',
      'schemaVersion': 1,
      'occurredAt': DateTime.now().toUtc().toIso8601String(),
      'payload': {'notes': notes.trim(), 'captureMode': 'manual'},
    });
    await into(inspections).insert(
      InspectionsCompanion.insert(id: id, scope: scope, envelope: envelope),
    );
    await into(outbox).insert(OutboxCompanion.insert(id: id, scope: scope));
    return id;
  });
  Future<List<OutboxData>> rows(String scope) =>
      (select(outbox)..where((t) => t.scope.equals(scope))).get();
  Future<Map<String, dynamic>> event(String id, String scope) async {
    final row = await (select(
      inspections,
    )..where((t) => t.id.equals(id) & t.scope.equals(scope))).getSingle();
    return jsonDecode(row.envelope) as Map<String, dynamic>;
  }

  Future<bool> claim(
    String id,
    String scope,
    DateTime now, {
    bool manual = false,
  }) async {
    final stamp = now.millisecondsSinceEpoch;
    final count =
        await (update(outbox)..where(
              (t) =>
                  t.id.equals(id) &
                  t.scope.equals(scope) &
                  ((t.status.isIn(['pending', 'retry']) &
                          (manual
                              ? (t.httpStatus.isNull() |
                                    t.httpStatus.equals(429).not() |
                                    t.nextAttempt.isSmallerOrEqualValue(stamp))
                              : t.nextAttempt.isSmallerOrEqualValue(stamp))) |
                      (t.status.equals('sending') &
                          t.leaseUntil.isSmallerOrEqualValue(stamp))),
            ))
            .write(
              OutboxCompanion(
                status: const Value('sending'),
                leaseUntil: Value(stamp + 90000),
              ),
            );
    return count == 1;
  }

  Future<void> acknowledge(String id, String scope, String ack) =>
      (update(
        outbox,
      )..where((t) => t.id.equals(id) & t.scope.equals(scope))).write(
        OutboxCompanion(
          status: const Value('synced'),
          ack: Value(ack),
          error: const Value(null),
          leaseUntil: const Value(null),
        ),
      );
  Future<void> failure(
    OutboxData row,
    String message, {
    bool rejected = false,
    bool paused = false,
    int? httpStatus,
    int? retryAfterSeconds,
  }) async {
    final attempts = row.attempts + 1;
    final backoff = (30 * (1 << attempts.clamp(0, 7))).clamp(30, 3600);
    final seconds = max(
      retryAfterSeconds ?? 0,
      backoff + Random().nextInt(max(1, backoff ~/ 4)),
    );
    await (update(
      outbox,
    )..where((t) => t.id.equals(row.id) & t.scope.equals(row.scope))).write(
      OutboxCompanion(
        status: Value(
          rejected
              ? 'rejected'
              : paused
              ? 'paused'
              : 'retry',
        ),
        attempts: Value(attempts),
        httpStatus: Value(httpStatus),
        error: Value(message),
        nextAttempt: Value(
          DateTime.now().millisecondsSinceEpoch + seconds * 1000,
        ),
        leaseUntil: const Value(null),
      ),
    );
  }

  Future<void> resume(String scope) =>
      (update(outbox)
            ..where((t) => t.scope.equals(scope) & t.status.equals('paused')))
          .write(const OutboxCompanion(status: Value('pending')));

  /// Explicit revalidation after device enrollment, preserving the original event.
  Future<int> retryAccessDenied(String id, String scope) =>
      (update(outbox)..where(
            (t) =>
                t.id.equals(id) &
                t.scope.equals(scope) &
                t.status.equals('rejected') &
                t.httpStatus.equals(403),
          ))
          .write(
            const OutboxCompanion(
              status: Value('pending'),
              nextAttempt: Value(0),
            ),
          );
}
