import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/system.dart';

/// Result of pushing the outbox to a backend.
class SyncResult {
  final int accepted;
  final int duplicates;
  final int rev;
  const SyncResult({this.accepted = 0, this.duplicates = 0, this.rev = 0});
}

/// EXPERIMENTAL — NOT wired end-to-end. BillNex's shipping data model is
/// per-shop local storage + the merchant's own device/Google-Drive backup (no
/// central multi-device sync). This seam and the `backend/` Supabase functions
/// are a prototype only: URLs, payload shapes and pull/apply are not complete,
/// and the client is not authenticated in `main.dart`. Do not present sync as a
/// production feature until it is finished and covered by contract tests.
///
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
  Future<SyncResult> push(List<OutboxEvent> events) async => SyncResult(accepted: events.length);

  @override
  Future<List<OutboxEvent>> pull({int sinceRev = 0}) async => const [];
}

/// Real backend client (P5). Talks to the Supabase Edge Functions in
/// `backend/functions/` per `backend/openapi.yaml`, authenticated with a
/// Supabase JWT. Pass an instance to [AppState] and `syncNow()` POSTs the outbox.
class HttpSyncService implements SyncService {
  HttpSyncService({required this.baseUrl, required this.jwt, http.Client? client}) : _client = client ?? http.Client();
  final String baseUrl; // e.g. https://<ref>.supabase.co/functions/v1
  final String jwt;
  final http.Client _client;

  Map<String, String> get _headers => {'Authorization': 'Bearer $jwt', 'Content-Type': 'application/json'};

  @override
  bool get isConfigured => baseUrl.isNotEmpty && jwt.isNotEmpty;

  @override
  Future<SyncResult> push(List<OutboxEvent> events) async {
    final res = await _client.post(Uri.parse('$baseUrl/sync/push'), headers: _headers, body: jsonEncode({'events': events.map((e) => e.toJson()).toList()}));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('sync/push failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return SyncResult(accepted: (body['accepted'] as num?)?.toInt() ?? events.length, duplicates: (body['duplicates'] as num?)?.toInt() ?? 0, rev: (body['rev'] as num?)?.toInt() ?? 0);
  }

  @override
  Future<List<OutboxEvent>> pull({int sinceRev = 0}) async {
    final res = await _client.get(Uri.parse('$baseUrl/sync/pull?since=$sinceRev'), headers: _headers);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('sync/pull failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return ((body['events'] as List?) ?? []).map((e) => OutboxEvent.fromJson(e as Map<String, dynamic>)).toList();
  }
}
