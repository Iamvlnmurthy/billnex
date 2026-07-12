import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'business_setup_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final AppState state;
  const OnboardingScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 60),
            child: Column(children: [
              // Hero
              _kicker(bx),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'Pick your business.\nWe '),
                  TextSpan(text: 'pre-configure', style: TextStyle(color: bx.brand)),
                  const TextSpan(text: ' the rest.'),
                ]),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 40, height: 1.05, fontWeight: FontWeight.w800, letterSpacing: -1.2),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  "Choose a business type and BillNex auto-enables exactly the features that trade needs — GST, credit, batch/expiry, KOT, appointments — nothing you don't. Fine-tune any category later.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: bx.muted, height: 1.5),
                ),
              ),
              const SizedBox(height: 22),
              _steps(bx),
              const SizedBox(height: 26),
              // Grid
              LayoutBuilder(builder: (context, c) {
                final cols = c.maxWidth > 900
                    ? 4
                    : c.maxWidth > 600
                        ? 2
                        : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kBusinessTypes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 224,
                  ),
                  itemBuilder: (context, i) => _BizCard(
                    biz: kBusinessTypes[i],
                    delayMs: i * 45,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BusinessSetupScreen(state: state, bizType: kBusinessTypes[i].key))),
                  ),
                );
              }),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _kicker(BxColors bx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.bolt, size: 15, color: bx.brand),
          const SizedBox(width: 6),
          Text('Guided setup · 60 seconds', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: bx.brand)),
        ]),
      );

  Widget _steps(BxColors bx) {
    Widget step(String n, String label, bool on) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 22, height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? bx.brand : bx.surface2,
              shape: BoxShape.circle,
              border: on ? null : Border.all(color: bx.border),
            ),
            child: Text(n, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: on ? Colors.white : bx.faint)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: on ? null : bx.faint)),
        ]);
    return Wrap(spacing: 16, runSpacing: 8, alignment: WrapAlignment.center, children: [
      step('1', 'Business type', true),
      step('2', 'Features auto-allotted', false),
      step('3', 'Templates & go live', false),
    ]);
  }
}

class _BizCard extends StatefulWidget {
  final BusinessType biz;
  final int delayMs;
  final VoidCallback onTap;
  const _BizCard({required this.biz, required this.delayMs, required this.onTap});
  @override
  State<_BizCard> createState() => _BizCardState();
}

class _BizCardState extends State<_BizCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final b = widget.biz;
    return FadeTransition(
      opacity: _c,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.translate(offset: Offset(0, 10 * (1 - _c.value)), child: child),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: _hover ? (Matrix4.identity()..translateByDouble(0, -3, 0, 1)) : Matrix4.identity(),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Bx.radius),
                border: Border.all(color: _hover ? bx.brand : bx.border),
                boxShadow: _hover
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 40, offset: const Offset(0, 20))]
                    : null,
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
                  child: Icon(b.icon, color: bx.brand, size: 23),
                ),
                const SizedBox(height: 12),
                Text(b.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Text(b.edition, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: bx.accent)),
                const SizedBox(height: 8),
                Text(b.tag, style: TextStyle(fontSize: 12.5, color: bx.muted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Wrap(spacing: 5, runSpacing: 5, children: [
                  ...b.on.take(2).map((c) => _tag(bx, capabilityByKey(c).name.split(' ').take(2).join(' '))),
                  _tag(bx, '+${b.on.length - 2} more'),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(BxColors bx, String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: bx.surface2, borderRadius: BorderRadius.circular(6), border: Border.all(color: bx.border)),
        child: Text(s, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: bx.muted)),
      );
}
