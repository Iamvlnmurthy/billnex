import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'common.dart';

/// Bottom sheet to search/select an existing customer or add a new one.
/// Returns the chosen [Customer], or null if dismissed.
Future<Customer?> pickCustomer(BuildContext context, AppState state) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _CustomerPickerSheet(state: state),
  );
}

class _CustomerPickerSheet extends StatefulWidget {
  final AppState state;
  const _CustomerPickerSheet({required this.state});
  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  String _q = '';
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final inset = MediaQuery.of(context).viewInsets.bottom;
    final matches = widget.state.customers.where((c) => c.name.toLowerCase().contains(_q.toLowerCase()) || c.mobile.contains(_q)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: _adding
            ? _AddForm(state: widget.state, initialName: _q, onDone: (c) => Navigator.pop(context, c), onCancel: () => setState(() => _adding = false))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Select customer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                            ),
                            TextButton.icon(onPressed: () => setState(() => _adding = true), icon: const Icon(Icons.person_add_alt, size: 18), label: const Text('New')),
                          ],
                        ),
                        TextField(
                          autofocus: true,
                          onChanged: (v) => setState(() => _q = v),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search name or mobile…',
                            filled: true,
                            fillColor: bx.surface2,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: matches.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                Text(
                                  _q.isEmpty ? 'No customers yet' : 'No match',
                                  style: TextStyle(color: bx.muted, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 10),
                                FilledButton.icon(
                                  onPressed: () => setState(() => _adding = true),
                                  icon: const Icon(Icons.person_add_alt, size: 18),
                                  label: Text(_q.isEmpty ? 'Add customer' : 'Add "$_q"'),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: matches.length,
                            separatorBuilder: (_, i) => Divider(height: 1, color: bx.border),
                            itemBuilder: (ctx, i) {
                              final c = matches[i];
                              final bal = widget.state.balanceOf(c.id);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: bx.brand.withValues(alpha: 0.12),
                                  child: Text(
                                    c.name.characters.first.toUpperCase(),
                                    style: TextStyle(color: bx.brand, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                subtitle: Text(c.mobile.isEmpty ? 'No mobile' : c.mobile),
                                trailing: bal > 0
                                    ? Text(
                                        '${money(bal)} due',
                                        style: TextStyle(color: bx.danger, fontWeight: FontWeight.w700, fontSize: 12.5),
                                      )
                                    : Text(
                                        'Settled',
                                        style: TextStyle(color: bx.pos, fontWeight: FontWeight.w700, fontSize: 12.5),
                                      ),
                                onTap: () => Navigator.pop(context, c),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
      ),
    );
  }
}

class _AddForm extends StatefulWidget {
  final AppState state;
  final String initialName;
  final ValueChanged<Customer> onDone;
  final VoidCallback onCancel;
  const _AddForm({required this.state, required this.initialName, required this.onDone, required this.onCancel});
  @override
  State<_AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<_AddForm> {
  late final _name = TextEditingController(text: widget.initialName);
  final _mobile = TextEditingController();
  final _gstin = TextEditingController();
  final _limit = TextEditingController();
  bool _consent = true;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _gstin.dispose();
    _limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(tooltip: L.of(context).backLabel, onPressed: widget.onCancel, icon: const Icon(Icons.arrow_back)),
              const Text('New customer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          _field(_name, 'Name', autofocus: true),
          const SizedBox(height: 10),
          _field(_mobile, 'Mobile', keyboard: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_gstin, 'GSTIN (optional)'),
          const SizedBox(height: 10),
          _field(_limit, 'Credit limit ₹ (0 = none)', keyboard: TextInputType.number),
          const SizedBox(height: 6),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _consent,
            onChanged: (v) => setState(() => _consent = v),
            title: const Text('Consent to reminders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Required before sending due reminders (PRD BNX-0235)', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              if (_name.text.trim().isEmpty) return;
              final c = widget.state.addCustomer(
                name: _name.text,
                mobile: _mobile.text,
                gstin: _gstin.text,
                creditLimit: double.tryParse(_limit.text) ?? 0,
                consent: _consent,
                nowMs: DateTime.now().millisecondsSinceEpoch,
              );
              widget.onDone(c);
            },
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Save & select'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboard, bool autofocus = false}) => TextField(
    controller: c,
    autofocus: autofocus,
    keyboardType: keyboard,
    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
  );
}
