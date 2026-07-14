import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/appointment.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/empty_state.dart';
import 'customers_screen.dart' show StatusChip;

String _apptStatusLabel(L l, ApptStatus s) => switch (s) {
  ApptStatus.booked => l.apptStatusBooked,
  ApptStatus.done => l.apptStatusDone,
  ApptStatus.noShow => l.apptStatusNoShow,
};

/// Appointments vertical pack (salon/clinic) — gated by the `appointments` flag.
class AppointmentsScreen extends StatefulWidget {
  final AppState state;
  const AppointmentsScreen({required this.state, super.key});
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String? _selectedId;

  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _book(context), icon: const Icon(Icons.event_available), label: Text(l.apptBook)),
      body: LayoutBuilder(builder: (context, c) => c.maxWidth >= 720 ? _wide(context) : _narrow(context)),
    );
  }

  Widget _narrow(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 100),
    children: [ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1180), child: _masterColumn(context, wide: false))],
  );

  Widget _wide(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final appt = state.appointments.where((x) => x.id == _selectedId).firstOrNull;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 360,
              child: ListView(padding: const EdgeInsets.fromLTRB(22, 24, 16, 100), children: [_masterColumn(context, wide: true)]),
            ),
            Container(width: 1, color: bx.border),
            Expanded(
              child: appt != null
                  ? AppointmentDetailView(state: state, appt: appt)
                  : Center(
                      child: EmptyState(illustration: 'empty-no-sales', title: l.selectItemTitle, subtitle: l.selectItemSub),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _masterColumn(BuildContext context, {required bool wide}) {
    final l = L.of(context);
    final bx = context.bx;
    final appts = state.appointments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeader(l.navAppointments, l.apptSubtitle('${state.upcomingAppts}'), trailing: wide ? null : Badge2(l.apptVerticalPack)),
        if (appts.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 44),
              child: Column(
                children: [
                  Icon(Icons.event_outlined, size: 40, color: bx.faint),
                  const SizedBox(height: 12),
                  Text(
                    l.apptEmptyTitle,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: bx.muted),
                  ),
                ],
              ),
            ),
          )
        else
          Card(
            child: Column(children: [for (int i = 0; i < appts.length; i++) _row(context, appts[i], i == 0, wide: wide)]),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, Appointment a, bool first, {required bool wide}) {
    final l = L.of(context);
    final bx = context.bx;
    final isSelected = wide && a.id == _selectedId;
    final (fg, bg) = switch (a.status) {
      ApptStatus.booked => (bx.accent, bx.accent.withValues(alpha: 0.12)),
      ApptStatus.done => (bx.pos, bx.posBg),
      ApptStatus.noShow => (bx.danger, bx.dangerBg),
    };
    final row = Container(
      decoration: BoxDecoration(
        color: isSelected ? bx.brand.withValues(alpha: 0.08) : null,
        border: Border(
          top: first ? BorderSide.none : BorderSide(color: bx.border),
          left: isSelected ? BorderSide(color: bx.brand, width: 3) : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(11)),
            child: Icon(Icons.calendar_month_outlined, color: bx.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        a.customer,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusChip(_apptStatusLabel(l, a.status).toUpperCase(), fg, bg),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${a.service} · ${a.staff} · ${a.slotLabel}', style: TextStyle(fontSize: 12, color: bx.muted)),
              ],
            ),
          ),
          if (a.status == ApptStatus.booked)
            PopupMenuButton<ApptStatus>(
              tooltip: l.more,
              icon: Icon(Icons.more_vert, color: bx.muted),
              onSelected: (s) => state.setApptStatus(a, s),
              itemBuilder: (ctx) => [PopupMenuItem(value: ApptStatus.done, child: Text(l.apptMarkDone)), PopupMenuItem(value: ApptStatus.noShow, child: Text(l.apptStatusNoShow))],
            ),
        ],
      ),
    );
    return wide ? InkWell(onTap: () => setState(() => _selectedId = a.id), child: row) : row;
  }

  Future<void> _book(BuildContext context) async {
    final l = L.of(context);
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
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setSt) => Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.apptBookTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: customer,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l.apptCustomer, border: const OutlineInputBorder()),
                    validator: (v) => (v ?? '').trim().isEmpty ? l.apptEnterCustomer : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: service,
                    decoration: InputDecoration(labelText: l.serviceLabel, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: staff,
                    decoration: InputDecoration(labelText: l.apptStaff, border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final t = await showTimePicker(context: ctx, initialTime: time);
                      if (t != null) setSt(() => time = t);
                    },
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(l.apptSlot(time.format(ctx))),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) Navigator.pop(ctx, true);
                    },
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(l.apptConfirmBooking),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (ok == true && customer.text.trim().isNotEmpty) {
        final now = DateTime.now();
        final slot = DateTime(now.year, now.month, now.day, time.hour, time.minute).millisecondsSinceEpoch;
        state.addAppointment(
          customer: customer.text.trim(),
          service: service.text.trim().isEmpty ? l.serviceLabel : service.text.trim(),
          staff: staff.text.trim().isEmpty ? l.apptStaff : staff.text.trim(),
          slotMs: slot,
          nowMs: DateTime.now().millisecondsSinceEpoch,
        );
        messenger.showSnackBar(SnackBar(content: Text(l.apptBookedSnack)));
      }
    } finally {
      customer.dispose();
      service.dispose();
      staff.dispose();
    }
  }
}

/// Read-only summary + status actions for the selected appointment (tablet pane).
class AppointmentDetailView extends StatelessWidget {
  final AppState state;
  final Appointment appt;
  const AppointmentDetailView({required this.state, required this.appt, super.key});

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final bx = context.bx;
    final (fg, bg) = switch (appt.status) {
      ApptStatus.booked => (bx.accent, bx.accent.withValues(alpha: 0.12)),
      ApptStatus.done => (bx.pos, bx.posBg),
      ApptStatus.noShow => (bx.danger, bx.dangerBg),
    };
    Widget line(IconData icon, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: bx.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                appt.customer,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(_apptStatusLabel(l, appt.status).toUpperCase(), fg, bg),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                line(Icons.design_services_outlined, appt.service),
                line(Icons.person_outline, appt.staff),
                line(Icons.schedule, appt.slotLabel),
                if (appt.status == ApptStatus.booked) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => state.setApptStatus(appt, ApptStatus.noShow),
                          icon: const Icon(Icons.person_off_outlined, size: 18),
                          label: Text(l.apptStatusNoShow),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(onPressed: () => state.setApptStatus(appt, ApptStatus.done), icon: const Icon(Icons.check, size: 18), label: Text(l.apptMarkDone)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
