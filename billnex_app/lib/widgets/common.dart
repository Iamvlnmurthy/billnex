import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/catalog.dart';

/// Indian-grouped currency, e.g. ₹1,12,400.
String money(num n) {
  final neg = n < 0;
  return '${neg ? '-' : ''}₹${_indianGroup(n.abs().round())}';
}

String _indianGroup(int v) {
  final s = v.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// Priority / status chip.
class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const Pill(this.label, {this.color = const Color(0xFF64748B), this.icon, super.key});

  factory Pill.priority(Priority p, BuildContext ctx) {
    final bx = ctx.bx;
    final c = switch (p) {
      Priority.must => bx.danger,
      Priority.should => const Color(0xFF2563EB),
      Priority.could => bx.faint,
    };
    return Pill(p.label, color: c);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(icon != null ? 6 : 9, 3, 9, 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        // ignore: use_null_aware_elements
        if (icon != null) Icon(icon, size: 12, color: color),
        if (icon != null) const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class Badge2 extends StatelessWidget {
  final String label;
  const Badge2(this.label, {super.key});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bx.surface2,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: bx.border),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bx.muted)),
    );
  }
}

/// Section header used on each screen.
class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const PageHeader(this.title, this.subtitle, {this.trailing, super.key});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 14, color: bx.muted, height: 1.4)),
          ]),
        ),
        ?trailing,
      ]),
    );
  }
}
