import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'business_setup_screen.dart';

/// First-run business picker — compact, fits one viewport, with a business-type
/// dropdown (no scrolling to hunt through a grid).
class OnboardingScreen extends StatefulWidget {
  final AppState state;
  const OnboardingScreen({required this.state, super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _key;

  BusinessType? get _biz => _key == null ? null : kBusinessTypes.firstWhere((b) => b.key == _key);

  void _continue() {
    if (_key == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BusinessSetupScreen(state: widget.state, bizType: _key!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final short = MediaQuery.of(context).size.height < 680; // hide art on small screens

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!short) ...[const Center(child: BxIllustration('illus-onboarding-business', size: 108)), const SizedBox(height: 14)],
                // kicker
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, size: 14, color: bx.brand),
                        const SizedBox(width: 6),
                        Text('Guided setup · 60 seconds', style: BxText.meta.copyWith(fontSize: 12, color: bx.brand)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Pick your business.\nWe '),
                      TextSpan(
                        text: 'pre-configure',
                        style: TextStyle(color: bx.brand),
                      ),
                      const TextSpan(text: ' the rest.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, height: 1.15, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                ),
                const SizedBox(height: 8),
                Text(
                  'Auto-enables exactly the features that trade needs — GST, credit, batch, KOT — nothing you don\'t.',
                  textAlign: TextAlign.center,
                  style: BxText.supporting.copyWith(color: bx.muted, height: 1.45),
                ),
                const SizedBox(height: 20),
                // ── business-type dropdown ──
                DropdownButtonFormField<String>(
                  initialValue: _key,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Business type',
                    prefixIcon: _biz == null
                        ? const Icon(Icons.storefront_outlined)
                        : Padding(
                            padding: const EdgeInsets.all(10),
                            child: BizIcon(bizKey: _biz!.key, fallback: _biz!.icon, size: 22),
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  hint: const Text('Choose your trade'),
                  items: [
                    for (final b in kBusinessTypes)
                      DropdownMenuItem(
                        value: b.key,
                        child: Text('${b.name}  ·  ${b.edition}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
                      ),
                  ],
                  onChanged: (v) => setState(() => _key = v),
                ),
                if (_biz != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bx.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: bx.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: bx.pos),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_biz!.tag, style: BxText.supporting.copyWith(color: bx.muted)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _key == null ? null : _continue,
                    icon: const Icon(Icons.arrow_forward, size: 20),
                    label: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                _steps(bx),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _steps(BxColors bx) {
    Widget step(String n, String label, bool on) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? bx.brand : bx.surface2,
            shape: BoxShape.circle,
            border: on ? null : Border.all(color: bx.border),
          ),
          child: Text(
            n,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: on ? Colors.white : bx.faint),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: on ? null : bx.faint),
        ),
      ],
    );
    return Wrap(spacing: 14, runSpacing: 8, alignment: WrapAlignment.center, children: [step('1', 'Business type', true), step('2', 'Auto-allotted', false), step('3', 'Go live', false)]);
  }
}
