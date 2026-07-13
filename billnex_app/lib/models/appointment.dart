/// Appointment for salon/clinic vertical packs (PRD VTX-0081, VTX-0162).
enum ApptStatus { booked, done, noShow }

extension ApptStatusX on ApptStatus {
  String get label => switch (this) {
    ApptStatus.booked => 'Booked',
    ApptStatus.done => 'Done',
    ApptStatus.noShow => 'No-show',
  };
  static ApptStatus fromCode(String c) => ApptStatus.values.firstWhere((s) => s.name == c, orElse: () => ApptStatus.booked);
}

class Appointment {
  final String id;
  final String customer;
  final String service;
  final String staff;
  final int epochMs; // slot time
  ApptStatus status;

  Appointment({required this.id, required this.customer, required this.service, required this.staff, required this.epochMs, this.status = ApptStatus.booked});

  String get slotLabel {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hh = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month - 1]} · $hh:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  Map<String, dynamic> toJson() => {'id': id, 'c': customer, 'sv': service, 'st': staff, 't': epochMs, 's': status.name};
  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
    id: j['id'] as String,
    customer: j['c'] as String,
    service: j['sv'] as String,
    staff: j['st'] as String,
    epochMs: (j['t'] as num).toInt(),
    status: ApptStatusX.fromCode(j['s'] as String),
  );
}
