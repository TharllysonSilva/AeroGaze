import '../database/field_database.dart';
import 'operations_api.dart';

class SyncRunner {
  SyncRunner(this.database, this.api);
  final FieldDatabase database;
  final OperationsApi api;
  bool _running = false;
  Future<void> run(
    ApiSession session,
    String farmId, {
    bool manual = false,
  }) async {
    if (_running) return;
    _running = true;
    final scope = session.scope(farmId);
    try {
      final device = await database.device(scope);
      for (final row in await database.rows(scope)) {
        if (!await database.claim(
          row.id,
          scope,
          DateTime.now(),
          manual: manual,
        )) {
          continue;
        }
        try {
          final ack = await api.send(
            session,
            farmId,
            device,
            await database.event(row.id, scope),
          );
          await database.acknowledge(row.id, scope, ack);
        } on ApiFailure catch (error) {
          await database.failure(
            row,
            error.message,
            rejected: [400, 403, 409, 422].contains(error.status),
            paused: error.status == 401,
            httpStatus: error.status,
            retryAfterSeconds: error.retryAfterSeconds,
          );
          if ([401, 403, 429].contains(error.status)) break;
        } catch (_) {
          await database.failure(
            row,
            'Tentativa interrompida; evento preservado para reenvio.',
          );
        }
      }
    } finally {
      _running = false;
    }
  }
}
