import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'customers_screen.dart' show StatusChip;

/// Appointments vertical pack (salon/clinic) — gated by the `appointments` flag.
class AppointmentsScreen extends StatelessWidget {
  final AppState state;
  const AppointmentsScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final appts = state.appointments;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _book(context),
        icon: const Icon(Icons.event_available),
        label: const Text('Book'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              PageHeader('Appointments', '${state.upcomingAppts} upcoming · book service, staff and slot.',
                  trailing: const Badge2('Vertical pack')),
              if (appts.isEmpty)
                Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 44), child: Column(children: [
                  Icon(Icons.event_outlined, size: 40, color: bx.faint),
                  const SizedBox(height: 12),
                  Text('No appointments yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: bx.muted)),
                ])))
              else
                Card(child: Column(children: [for (int i = 0; i < appts.length; i++) _row(context, appts[i], i == 0)])),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, Appointment a, bool first) {
    final bx = context.bx;
    final (fg, bg) = switch (a.status) {
      ApptStatus.booked => (bx.accent, bx.accent.withValues(alpha: 0.12)),
      ApptStatus.done => (bx.pos, bx.posBg),
      ApptStatus.noShow => (bx.danger, bx.dangerBg),
    };
    return Container(
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: bx.border))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(11)),
          child: Icon(Icons.calendar_month_outlined, color: bx.brand),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(a.customer, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              StatusChip(a.status.label.toUpperCase(), fg, bg),
            ]),
            const SizedBox(height: 2),
            Text('${a.service} · ${a.staff} · ${a.slotLabel}', style: TextStyle(fontSize: 12, color: bx.muted)),
          ]),
        ),
        if (a.status == ApptStatus.booked)
          PopupMenuButton<ApptStatus>(
            icon: Icon(Icons.more_vert, color: bx.muted),
            onSelected: (s) => state.setApptStatus(a, s),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: ApptStatus.done, child: Text('Mark done')),
              PopupMenuItem(value: ApptStatus.noShow, child: Text('No-show')),
            ],
          ),
      ]),
    );
  }

  Future<void> _book(BuildContext context) async {
    final customer = TextEditingController();
    final service = TextEditingController();
    final staff = TextEditingController();
    final formKey = GlobalKey<FormState>();
    TimeOfDay time = const TimeOfDay(hour: 10, minute: 0);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Book appointment', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextFormField(controller: customer, autofocus: true, decoration: const InputDecoration(labelText: 'Customer', border: OutlineInputBorder()), validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a customer name' : null),
              const SizedBox(height: 10),
              TextFormField(controller: service, decoration: const InputDecoration(labelText: 'Service', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextFormField(controller: staff, decoration: const InputDecoration(labelText: 'Staff', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final t = await showTimePicker(context: ctx, initialTime: time);
                  if (t != null) setSt(() => time = t);
                },
                icon: const Icon(Icons.schedule, size: 18),
                label: Text('Slot · ${time.format(ctx)}'),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: () { if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true); }, style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Confirm booking')),
            ]),
          ),
        )),
      );
      if (ok == true && customer.text.trim().isNotEmpty) {
        final now = DateTime.now();
        final slot = DateTime(now.year, now.month, now.day, time.hour, time.minute).millisecondsSinceEpoch;
        state.addAppointment(
          customer: customer.text.trim(),
          service: service.text.trim().isEmpty ? 'Service' : service.text.trim(),
          staff: staff.text.trim().isEmpty ? 'Staff' : staff.text.trim(),
          slotMs: slot,
          nowMs: DateTime.now().millisecondsSinceEpoch,
        );
        messenger.showSnackBar(const SnackBar(content: Text('Appointment booked ✓')));
      }
    } finally {
      customer.dispose();
      service.dispose();
      staff.dispose();
    }
  }
}
