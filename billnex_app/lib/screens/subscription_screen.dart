import 'package:flutter/material.dart';
import '../services/license_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'customers_screen.dart' show StatusChip;

/// Billing paywall: returns true if posting a bill is allowed. When the licence
/// has fully expired it blocks and offers to open the Subscription screen. Data
/// stays viewable/exportable — only creating new bills is gated.
Future<bool> ensureBillingAllowed(BuildContext context) async {
  if (!LicenseService.instance.isBillingLocked) return true;
  final l = L.of(context);
  final navigator = Navigator.of(context);
  final renew = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.subStatusExpired),
      content: Text(l.subExpiredLockNote),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.subRenew)),
      ],
    ),
  );
  if (renew == true) {
    navigator.push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
  }
  return false;
}

/// Subscription / licence screen: current status + expiry, plan cards, and an
/// activation-key box. Payments are Phase-2 — for now "Buy" requests a plan on
/// WhatsApp and the merchant pastes back the activation key they receive.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _keyC = TextEditingController();
  bool _activating = false;

  @override
  void dispose() {
    _keyC.dispose();
    super.dispose();
  }

  String _dateLabel(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Future<void> _activate() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _activating = true);
    final ok = await LicenseService.instance.activate(_keyC.text);
    if (!mounted) return;
    setState(() => _activating = false);
    messenger.showSnackBar(SnackBar(content: Text(ok ? l.subActivated : l.subInvalidKey)));
    if (ok) _keyC.clear();
  }

  Future<void> _buy(String planLabel) async {
    final l = L.of(context);
    await PdfService.run(context, () => PdfService.whatsAppText(l.subBuyMessage(planLabel)), failure: l.whatsappFail);
  }

  ({Color fg, Color bg, String label}) _statusChip(BxColors bx, L l, LicenseStatus s) => switch (s) {
        LicenseStatus.trialing => (fg: bx.accent, bg: bx.accent.withValues(alpha: 0.12), label: l.subStatusTrial),
        LicenseStatus.active => (fg: bx.pos, bg: bx.posBg, label: l.subStatusActive),
        LicenseStatus.grace => (fg: bx.warn, bg: bx.warnBg, label: l.subStatusGrace),
        LicenseStatus.expired => (fg: bx.danger, bg: bx.dangerBg, label: l.subStatusExpired),
      };

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.subTitle)),
      body: AnimatedBuilder(
        animation: LicenseService.instance,
        builder: (context, _) {
          final lic = LicenseService.instance;
          final s = lic.status;
          final chip = _statusChip(bx, l, s);
          final expired = s == LicenseStatus.expired;
          final grace = s == LicenseStatus.grace;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Status card ──
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StatusChip(chip.label, chip.fg, chip.bg),
                                  const Spacer(),
                                  if (!expired && lic.daysLeft >= 0)
                                    Text(l.subDaysLeft('${lic.daysLeft}'), style: TextStyle(fontWeight: FontWeight.w700, color: lic.daysLeft <= 15 ? bx.warn : bx.muted)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                expired ? l.subExpiredOn(_dateLabel(lic.expiryDate)) : l.subExpiresOn(_dateLabel(lic.expiryDate)),
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                              if (grace || expired) ...[
                                const SizedBox(height: 8),
                                Text(expired ? l.subExpiredLockNote : l.subGraceNote, style: TextStyle(fontSize: 12.5, color: bx.muted, height: 1.4)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(l.subChoosePlan, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(l.subBuyNote, style: TextStyle(fontSize: 12, color: bx.faint, height: 1.35)),
                      const SizedBox(height: 12),
                      _plan(bx, l, l.planMonthly, '₹199', l.perMonth, null),
                      const SizedBox(height: 10),
                      _plan(bx, l, l.planYearly, '₹1,499', l.perYear, l.subBestValue),
                      const SizedBox(height: 10),
                      _plan(bx, l, l.planLifetime, '₹4,999', l.oneTime, null),
                      const SizedBox(height: 24),
                      // ── Activation ──
                      Text(l.subHaveKey, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _keyC,
                        maxLines: 2,
                        minLines: 1,
                        decoration: InputDecoration(labelText: l.subEnterKey, border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: _activating ? null : _activate,
                        icon: _activating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.key, size: 18),
                        label: Text(l.subActivate),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _plan(BxColors bx, L l, String name, String price, String per, String? badge) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      StatusChip(badge, bx.pos, bx.posBg),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 3),
                    Text(per, style: TextStyle(fontSize: 12, color: bx.muted)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _buy(name),
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: Text(l.subBuy),
              style: FilledButton.styleFrom(backgroundColor: bx.brand, foregroundColor: bx.onAccent),
            ),
          ],
        ),
      ),
    );
  }
}
