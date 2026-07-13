/// User roles (PRD §9 permission model).
enum Role { owner, manager, cashier, accountant }

extension RoleX on Role {
  String get label => switch (this) {
    Role.owner => 'Owner',
    Role.manager => 'Manager',
    Role.cashier => 'Cashier',
    Role.accountant => 'Accountant',
  };
  static Role fromCode(String c) => Role.values.firstWhere((r) => r.name == c, orElse: () => Role.owner);
}

/// An outbox event for the offline-first sync queue (PRD §14).
/// Carries an idempotency key so replays are safe.
class OutboxEvent {
  final String idemKey;
  final String kind; // sale, collection, purchase, adjustment, payment
  final String ref;
  final int epochMs;
  bool synced;

  OutboxEvent({required this.idemKey, required this.kind, required this.ref, required this.epochMs, this.synced = false});

  Map<String, dynamic> toJson() => {'k': idemKey, 't': kind, 'r': ref, 'e': epochMs, 's': synced};
  factory OutboxEvent.fromJson(Map<String, dynamic> j) =>
      OutboxEvent(idemKey: j['k'] as String, kind: j['t'] as String, ref: j['r'] as String, epochMs: (j['e'] as num).toInt(), synced: j['s'] == true);
}

/// An immutable audit event (PRD BNX-0268).
class AuditEvent {
  final int epochMs;
  final String actor; // role label
  final String action;
  final String ref;

  const AuditEvent({required this.epochMs, required this.actor, required this.action, required this.ref});

  String get timeLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  Map<String, dynamic> toJson() => {'t': epochMs, 'a': actor, 'x': action, 'r': ref};
  factory AuditEvent.fromJson(Map<String, dynamic> j) => AuditEvent(epochMs: (j['t'] as num).toInt(), actor: j['a'] as String, action: j['x'] as String, ref: j['r'] as String);
}
