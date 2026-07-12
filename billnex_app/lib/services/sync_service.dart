import '../models/system.dart';

/// Result of pushing the outbox to a backend.
class SyncResult {
  final int accepted;
  final int duplicates;
  final int rev;
  const SyncResult({this.accepted = 0, this.duplicates = 0, this.rev = 0});
}

/// The server-sync seam (PRD §14). [AppState.syncNow] flushes the local outbox;
/// a real backend implementation POSTs those events to `/sync/push` (see
/// `backend/openapi.yaml`). Kept behind an interface so the app runs fully
/// offline with [NoopSyncService] and gains real sync by swapping the impl —
/// no business-logic changes.
abstract interface class SyncService {
  bool get isConfigured;

  /// Push unsynced events; idempotency keys make retries safe server-side.
  Future<SyncResult> push(List<OutboxEvent> events);

  /// Pull events created after [sinceRev] on other devices/branches.
  Future<List<OutboxEvent>> pull({int sinceRev = 0});
}

/// Default: no backend configured. Everything stays local; push is a no-op that
/// reports success so the offline outbox drains exactly as before.
class NoopSyncService implements SyncService {
  const NoopSyncService();

  @override
  bool get isConfigured => false;

  @override
  Future<SyncResult> push(List<OutboxEvent> events) async =>
      SyncResult(accepted: events.length);

  @override
  Future<List<OutboxEvent>> pull({int sinceRev = 0}) async => const [];
}

/// Skeleton for the real backend (P5 deploy step). Wire against
/// `backend/openapi.yaml` using package:http and a Supabase JWT:
///
/// ```dart
/// final r = await http.post(
///   Uri.parse('$baseUrl/sync/push'),
///   headers: {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'},
///   body: jsonEncode({'events': events.map((e) => e.toJson()).toList()}),
/// );
/// ```
/// Left unimplemented so the repo has no half-wired network dependency; the
/// contract and Postgres schema/RLS ship in `backend/`.
class HttpSyncService implements SyncService {
  HttpSyncService({required this.baseUrl, required this.jwt});
  final String baseUrl;
  final String jwt;

  @override
  bool get isConfigured => baseUrl.isNotEmpty && jwt.isNotEmpty;

  @override
  Future<SyncResult> push(List<OutboxEvent> events) =>
      throw UnimplementedError('Wire against backend/openapi.yaml with package:http');

  @override
  Future<List<OutboxEvent>> pull({int sinceRev = 0}) =>
      throw UnimplementedError('Wire against backend/openapi.yaml with package:http');
}
