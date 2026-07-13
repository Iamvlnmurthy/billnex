import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../models/business_profile.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// First-run business setup (or later edit). Captures the merchant's real
/// identity — printed on every invoice.
class BusinessSetupScreen extends StatefulWidget {
  final AppState state;
  final String bizType;
  final BusinessProfile? existing; // non-null when editing
  const BusinessSetupScreen({required this.state, required this.bizType, this.existing, super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _form = GlobalKey<FormState>();
  late final _shop = TextEditingController(text: widget.existing?.shopName ?? '');
  late final _owner = TextEditingController(text: widget.existing?.owner ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _gstin = TextEditingController(text: widget.existing?.gstin ?? '');
  late final _addr = TextEditingController(text: widget.existing?.address ?? '');
  late final _state = TextEditingController(text: widget.existing?.stateCode ?? '36');
  late bool _taxIncl = widget.existing?.taxInclusive ?? true;
  late String _type = widget.bizType; // editable — can be chosen/changed here

  bool get _editing => widget.existing != null;

  @override
  void dispose() {
    for (final c in [_shop, _owner, _phone, _gstin, _addr, _state]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final p = BusinessProfile(
      bizType: _type,
      shopName: _shop.text.trim(),
      owner: _owner.text.trim(),
      phone: _phone.text.trim(),
      gstin: _gstin.text.trim().isEmpty ? null : _gstin.text.trim().toUpperCase(),
      address: _addr.text.trim(),
      stateCode: _state.text.trim().isEmpty ? '36' : _state.text.trim(),
      taxInclusive: _taxIncl,
    );
    if (_editing) {
      widget.state.updateProfile(p);
    } else {
      widget.state.setupBusiness(p);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final typeChanged = _editing && _type != widget.existing!.bizType;
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Business details' : 'Set up your business')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Business type is editable — choose it here (or change it
                  // later); the features re-align to it, data is untouched.
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Business type', border: OutlineInputBorder()),
                    items: [
                      for (final b in kBusinessTypes)
                        DropdownMenuItem(
                          value: b.key,
                          child: Text('${b.name}  ·  ${b.edition}', overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? _type),
                  ),
                  if (typeChanged)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 15, color: bx.accent),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('Features will re-align to this type. Your items, customers and bills stay as they are.', style: TextStyle(fontSize: 12, color: bx.muted)),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  _field(_shop, 'Shop / business name *', hint: 'e.g. Rajesh Kirana Store', validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null, autofocus: !_editing),
                  _field(_owner, 'Owner name', hint: 'e.g. Rajesh Kumar'),
                  _field(
                    _phone,
                    'Phone',
                    keyboard: TextInputType.phone,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      return RegExp(r'^[0-9]{10}$').hasMatch(t) ? null : 'Enter a 10-digit phone';
                    },
                  ),
                  _field(
                    _gstin,
                    'GSTIN (optional)',
                    hint: '15-character GST number',
                    caps: true,
                    validator: (v) => (v != null && v.trim().isNotEmpty && v.trim().length != 15) ? 'GSTIN must be 15 characters' : null,
                  ),
                  _field(_addr, 'Address', maxLines: 2),
                  _field(
                    _state,
                    'GST state code',
                    keyboard: TextInputType.number,
                    hint: '36 = Telangana',
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      return RegExp(r'^[0-9]{2}$').hasMatch(t) ? null : '2-digit code (e.g. 36)';
                    },
                  ),
                  const SizedBox(height: 4),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _taxIncl,
                    onChanged: (v) => setState(() => _taxIncl = v),
                    title: const Text('Prices include GST', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(_taxIncl ? 'Tax is inside the price (MRP style)' : 'Tax is added on top at billing', style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(_editing ? Icons.check : Icons.arrow_forward, size: 18),
                    label: Text(_editing ? 'Save changes' : 'Create my shop'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                  if (!_editing)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'You can change any of this later in Settings. Your catalogue starts empty — add your own products next.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: bx.faint),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {String? hint, TextInputType? keyboard, int maxLines = 1, bool caps = false, bool autofocus = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        autofocus: autofocus,
        textCapitalization: caps ? TextCapitalization.characters : TextCapitalization.words,
        validator: validator,
        decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      ),
    );
  }
}
