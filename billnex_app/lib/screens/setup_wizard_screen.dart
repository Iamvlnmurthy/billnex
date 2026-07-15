import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../data/catalog.dart';
import '../data/catalog_i18n.dart';
import '../l10n/app_localizations.dart';
import '../models/business_profile.dart';
import '../services/data_io.dart';
import '../services/google_auth_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// First-run **Setup Wizard** — a multi-step, fully-optional guided setup.
///
/// Every step is individually skippable and there is a global "Skip setup"
/// affordance on every step. Whatever the merchant does (or skips), the wizard
/// guarantees the app ends up onboarded ([AppState.onboarded] == true) before
/// [onDone] fires — either from the chosen business type or a generic store.
///
/// Self-contained: it owns no navigation of its own beyond the internal
/// [PageView]. The parent supplies [onDone] to dismiss the wizard / enter the
/// app, and may inject a [googleAuth] (defaults to the dependency-free stub).
class SetupWizardScreen extends StatefulWidget {
  final AppState state;
  final GoogleAuthService googleAuth;
  final VoidCallback onDone;

  const SetupWizardScreen({required this.state, required this.onDone, this.googleAuth = const StubGoogleAuthService(), super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  static const _stepCount = 5;
  final _page = PageController();
  int _index = 0;

  AppState get _state => widget.state;

  // ── captured inputs (all optional) ──
  final _shop = TextEditingController();
  final _gstin = TextEditingController();
  String? _bizKey;
  bool _taxInclusive = true;
  GoogleAccount? _account;

  // transient UI flags
  bool _busy = false;
  bool _onboardedHere = false; // guards against re-applying the preset
  int _sampleCount = 0;

  @override
  void dispose() {
    _page.dispose();
    _shop.dispose();
    _gstin.dispose();
    super.dispose();
  }

  // ── navigation ─────────────────────────────────────────────────────────
  Future<void> _goTo(int i) async {
    if (i < 0 || i >= _stepCount) return;
    // Ensure the business exists before the inventory step so sample/CSV items
    // land on a freshly-applied preset (applyPreset clears stock — we must not
    // run it again afterwards).
    if (i >= 3) _ensureOnboarded();
    setState(() => _index = i);
    await _page.animateToPage(i, duration: const Duration(milliseconds: 260), curve: Curves.easeInOut);
  }

  void _next() => _goTo(_index + 1);
  void _back() => _goTo(_index - 1);

  /// Set up the business exactly once, from the chosen type (or a generic store
  /// when the merchant skipped selection). Never clears an already-onboarded
  /// catalogue.
  void _ensureOnboarded() {
    final shop = _shop.text.trim();
    final gst = _gstin.text.trim();
    final firstTime = !(_onboardedHere || _state.onboarded);

    if (firstTime) {
      if (_bizKey != null) {
        _state.setupBusiness(BusinessProfile(
          bizType: _bizKey!,
          shopName: shop.isEmpty ? businessByKey(_bizKey!).name : shop,
          gstin: gst.isEmpty ? null : gst.toUpperCase(),
          taxInclusive: _taxInclusive,
        ));
      } else {
        _state.setupGenericStore();
        if (shop.isNotEmpty || gst.isNotEmpty || !_taxInclusive) {
          final base = _state.profile ?? const BusinessProfile(bizType: 'kirana', shopName: 'My Store');
          _state.updateProfile(base.copyWith(shopName: shop.isEmpty ? base.shopName : shop, gstin: gst.isEmpty ? base.gstin : gst.toUpperCase(), taxInclusive: _taxInclusive));
        }
      }
      _onboardedHere = true;
      return;
    }

    // Already onboarded — honour edits made by navigating BACK. Re-run the preset
    // ONLY when the business type actually changed (applyPreset clears stock);
    // otherwise just update the editable profile fields (no stock reset).
    if (_bizKey != null && _bizKey != _state.bizKey) {
      _state.setupBusiness(BusinessProfile(
        bizType: _bizKey!,
        shopName: shop.isEmpty ? businessByKey(_bizKey!).name : shop,
        gstin: gst.isEmpty ? null : gst.toUpperCase(),
        taxInclusive: _taxInclusive,
      ));
    } else {
      final base = _state.profile ?? BusinessProfile(bizType: _state.bizKey ?? 'kirana', shopName: 'My Store');
      _state.updateProfile(base.copyWith(
        shopName: shop.isEmpty ? base.shopName : shop,
        gstin: gst.isEmpty ? base.gstin : gst.toUpperCase(),
        taxInclusive: _taxInclusive,
      ));
    }
  }

  /// Finish (or globally skip) — guarantee onboarding, then hand back.
  void _finish() {
    _ensureOnboarded();
    widget.onDone();
  }

  // ── step 1: account ────────────────────────────────────────────────────
  Future<void> _google() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final acc = await widget.googleAuth.signIn();
      if (!mounted) return;
      if (acc == null) {
        messenger.showSnackBar(SnackBar(content: Text(l.wizardGoogleUnavailable)));
      } else {
        setState(() => _account = acc);
      }
    } on GoogleAuthUnavailable {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.wizardGoogleUnavailable)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l.wizardGoogleUnavailable)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) _next();
  }

  // ── step 4: inventory ──────────────────────────────────────────────────
  void _loadSample() {
    final l = L.of(context);
    _ensureOnboarded();
    final bizKey = _state.bizKey ?? 'kirana';
    final base = DateTime.now().millisecondsSinceEpoch;
    final prods = productsFor(bizKey);
    var added = 0;
    for (var i = 0; i < prods.length; i++) {
      final p = prods[i];
      final ok = _state.addStockItem(name: p.name, unit: p.unit, price: p.price, nowMs: base + i);
      if (ok != null) added++;
    }
    setState(() => _sampleCount = _state.stockItems.length);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.wizardSampleAdded(added))));
  }

  Future<void> _importCsv() async {
    final l = L.of(context);
    final messenger = ScaffoldMessenger.of(context);
    _ensureOnboarded();
    setState(() => _busy = true);
    try {
      final res = await FilePicker.platform.pickFiles(dialogTitle: l.importInventoryCsv, type: FileType.custom, allowedExtensions: const ['csv'], withData: true);
      final bytes = res?.files.single.bytes;
      if (bytes == null) {
        messenger.showSnackBar(SnackBar(content: Text(l.exportCancelled)));
        return;
      }
      final text = utf8.decode(bytes, allowMalformed: true);
      final base = DateTime.now().millisecondsSinceEpoch;
      var i = 0;
      final r = importInventoryCsv(
        text,
        add: (row) =>
            _state.addStockItem(
              name: row.name,
              unit: row.unit,
              price: row.price,
              cost: row.cost,
              qty: row.qty,
              reorder: row.reorder,
              gstRate: row.gstRate,
              barcode: row.barcode,
              category: row.category,
              hsn: row.hsn,
              stockTracked: row.stockTracked,
              nowMs: base + i++,
            ) !=
            null,
      );
      if (!mounted) return;
      setState(() => _sampleCount = _state.stockItems.length);
      messenger.showSnackBar(SnackBar(content: Text(r.isEmpty ? l.importNothing : l.importSummary(r.added, r.skipped, r.failed))));
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text(l.csvImportFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── build ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(index: _index, count: _stepCount, onSkipAll: _finish, onBack: _index == 0 ? null : _back),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AccountStep(l: l, bx: bx, account: _account, busy: _busy, onGoogle: _busy ? null : _google, onSkip: _busy ? null : _next),
                  _BusinessStep(l: l, bx: bx, shop: _shop, bizKey: _bizKey, onBiz: (v) => setState(() => _bizKey = v), onContinue: _next),
                  _GstStep(l: l, bx: bx, gstin: _gstin, taxInclusive: _taxInclusive, onTax: (v) => setState(() => _taxInclusive = v), onContinue: _next),
                  _InventoryStep(l: l, bx: bx, busy: _busy, count: _sampleCount, onSample: _busy ? null : _loadSample, onImport: _busy ? null : _importCsv, onContinue: _next),
                  _DoneStep(l: l, bx: bx, shopName: _shop.text.trim(), bizKey: _bizKey, gstin: _gstin.text.trim(), items: _sampleCount, account: _account, onEnter: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Top bar: segmented progress + global skip
// ═══════════════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final int index;
  final int count;
  final VoidCallback onSkipAll;
  final VoidCallback? onBack;
  const _TopBar({required this.index, required this.count, required this.onSkipAll, this.onBack});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: onBack == null ? null : IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back), tooltip: MaterialLocalizations.of(context).backButtonTooltip),
              ),
              Expanded(
                child: Text(
                  l.wizardStepOf(index + 1, count),
                  textAlign: TextAlign.center,
                  style: BxText.meta.copyWith(color: bx.faint),
                ),
              ),
              SizedBox(
                width: 96,
                height: 44,
                child: TextButton(
                  onPressed: onSkipAll,
                  child: Text(
                    l.wizardSkipSetup,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: bx.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      height: 6,
                      decoration: BoxDecoration(color: i <= index ? bx.accent : bx.border, borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared step scaffold
// ═══════════════════════════════════════════════════════════════════════════
class _StepShell extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final List<Widget> children;
  const _StepShell({required this.icon, required this.tint, required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                      child: Icon(icon, color: tint, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(title, style: BxText.pageTitle),
                    const SizedBox(height: 8),
                    Text(subtitle, style: BxText.supporting.copyWith(color: bx.muted, height: 1.45)),
                    const SizedBox(height: 22),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _primary(BuildContext context, {required IconData icon, required String label, required VoidCallback? onTap}) => SizedBox(
  height: 52,
  child: FilledButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 20),
    label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
  ),
);

Widget _skipLink(BuildContext context, String label, VoidCallback? onTap) {
  final bx = context.bx;
  return Padding(
    padding: const EdgeInsets.only(top: 6),
    child: SizedBox(
      height: 44,
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: bx.muted),
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 1 — Welcome / account
// ═══════════════════════════════════════════════════════════════════════════
class _AccountStep extends StatelessWidget {
  final L l;
  final BxColors bx;
  final GoogleAccount? account;
  final bool busy;
  final VoidCallback? onGoogle;
  final VoidCallback? onSkip;
  const _AccountStep({required this.l, required this.bx, required this.account, required this.busy, required this.onGoogle, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      icon: Icons.waving_hand_outlined,
      tint: bx.brand,
      title: l.wizardWelcomeTitle,
      subtitle: l.wizardWelcomeSubtitle,
      children: [
        if (account != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bx.posBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bx.border),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: bx.pos),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.wizardSignedInAs(account!.email),
                    style: BxText.supporting.copyWith(color: bx.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: onGoogle,
              icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.account_circle_outlined, size: 20),
              label: Text(l.wizardContinueWithGoogle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        const SizedBox(height: 10),
        _primary(context, icon: Icons.arrow_forward, label: l.wizardContinueWithoutAccount, onTap: onSkip),
        _skipLink(context, l.wizardSkipStep, onSkip),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 2 — Business
// ═══════════════════════════════════════════════════════════════════════════
class _BusinessStep extends StatelessWidget {
  final L l;
  final BxColors bx;
  final TextEditingController shop;
  final String? bizKey;
  final ValueChanged<String?> onBiz;
  final VoidCallback onContinue;
  const _BusinessStep({required this.l, required this.bx, required this.shop, required this.bizKey, required this.onBiz, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      icon: Icons.storefront_outlined,
      tint: bx.accent,
      title: l.wizardBusinessTitle,
      subtitle: l.wizardBusinessSubtitle,
      children: [
        TextField(
          controller: shop,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l.shopBusinessName, hintText: l.shopNameHint, prefixIcon: const Icon(Icons.store_mall_directory_outlined)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: bizKey,
          isExpanded: true,
          decoration: InputDecoration(labelText: l.businessType, prefixIcon: const Icon(Icons.category_outlined)),
          hint: Text(l.chooseYourTrade),
          items: [
            for (final b in kBusinessTypes)
              DropdownMenuItem(
                value: b.key,
                child: Text('${businessTypeName(l, b.key)}  ·  ${businessTypeEdition(l, b.key)}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
              ),
          ],
          onChanged: onBiz,
        ),
        const SizedBox(height: 18),
        _primary(context, icon: Icons.arrow_forward, label: l.continueLabel, onTap: onContinue),
        _skipLink(context, l.wizardSkipUseStandardStore, onContinue),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 3 — GST
// ═══════════════════════════════════════════════════════════════════════════
class _GstStep extends StatelessWidget {
  final L l;
  final BxColors bx;
  final TextEditingController gstin;
  final bool taxInclusive;
  final ValueChanged<bool> onTax;
  final VoidCallback onContinue;
  const _GstStep({required this.l, required this.bx, required this.gstin, required this.taxInclusive, required this.onTax, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      icon: Icons.receipt_long_outlined,
      tint: bx.brand,
      title: l.wizardGstTitle,
      subtitle: l.wizardGstSubtitle,
      children: [
        TextField(
          controller: gstin,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: l.gstinOptional, hintText: l.gstinHint, prefixIcon: const Icon(Icons.badge_outlined)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: bx.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: bx.border),
          ),
          child: SwitchListTile(
            value: taxInclusive,
            onChanged: onTax,
            title: Text(l.pricesIncludeGst, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            subtitle: Text(taxInclusive ? l.taxInsidePrice : l.taxAddedOnTop, style: const TextStyle(fontSize: 12)),
          ),
        ),
        const SizedBox(height: 18),
        _primary(context, icon: Icons.arrow_forward, label: l.continueLabel, onTap: onContinue),
        _skipLink(context, l.wizardSkipStep, onContinue),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 4 — Inventory
// ═══════════════════════════════════════════════════════════════════════════
class _InventoryStep extends StatelessWidget {
  final L l;
  final BxColors bx;
  final bool busy;
  final int count;
  final VoidCallback? onSample;
  final VoidCallback? onImport;
  final VoidCallback onContinue;
  const _InventoryStep({required this.l, required this.bx, required this.busy, required this.count, required this.onSample, required this.onImport, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      icon: Icons.inventory_2_outlined,
      tint: bx.accent,
      title: l.wizardInventoryTitle,
      subtitle: l.wizardInventorySubtitle,
      children: [
        _choice(context, icon: Icons.auto_awesome_outlined, title: l.wizardLoadSample, subtitle: l.wizardLoadSampleHint, onTap: onSample),
        const SizedBox(height: 10),
        _choice(context, icon: Icons.file_download_outlined, title: l.importInventoryCsv, subtitle: l.wizardImportCsvHint, onTap: onImport),
        if (count > 0) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 16, color: bx.pos),
              const SizedBox(width: 6),
              Text(
                l.wizardItemsInCatalogue(count),
                style: BxText.supporting.copyWith(color: bx.pos, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        _primary(context, icon: Icons.arrow_forward, label: l.continueLabel, onTap: onContinue),
        _skipLink(context, l.wizardSkipForNow, onContinue),
      ],
    );
  }

  Widget _choice(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback? onTap}) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: Material(
        color: bx.surface2,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bx.border),
            ),
            child: Row(
              children: [
                Icon(icon, color: bx.accent, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: BxText.supporting.copyWith(color: bx.faint)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: bx.faint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Step 5 — All set
// ═══════════════════════════════════════════════════════════════════════════
class _DoneStep extends StatelessWidget {
  final L l;
  final BxColors bx;
  final String shopName;
  final String? bizKey;
  final String gstin;
  final int items;
  final GoogleAccount? account;
  final VoidCallback onEnter;
  const _DoneStep({required this.l, required this.bx, required this.shopName, required this.bizKey, required this.gstin, required this.items, required this.account, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    final biz = bizKey == null ? l.wizardStandardStore : businessTypeName(l, bizKey!);
    final shop = shopName.isEmpty ? (bizKey == null ? l.wizardStandardStore : businessByKey(bizKey!).name) : shopName;
    return _StepShell(
      icon: Icons.rocket_launch_outlined,
      tint: bx.pos,
      title: l.wizardDoneTitle,
      subtitle: l.wizardDoneSubtitle,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bx.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: bx.border),
          ),
          child: Column(
            children: [
              _row(context, Icons.storefront_outlined, l.wizardBusinessTitle, '$shop · $biz'),
              _row(context, Icons.receipt_long_outlined, l.pricesIncludeGst, gstin.isEmpty ? l.wizardNotSet : gstin),
              _row(context, Icons.inventory_2_outlined, l.wizardInventoryTitle, l.wizardItemsInCatalogue(items), last: true),
              if (account != null) ...[
                Divider(height: 20, color: bx.border),
                Row(
                  children: [
                    Icon(Icons.account_circle_outlined, size: 18, color: bx.muted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        account!.email,
                        style: BxText.supporting.copyWith(color: bx.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        _primary(context, icon: Icons.check, label: l.wizardEnterApp, onTap: onEnter),
      ],
    );
  }

  Widget _row(BuildContext context, IconData icon, String label, String value, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: bx.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: BxText.supporting.copyWith(color: bx.faint)),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
