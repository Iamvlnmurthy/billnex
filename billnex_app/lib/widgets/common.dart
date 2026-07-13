import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/catalog.dart';
import '../data/catalog_i18n.dart';
import '../l10n/app_localizations.dart';

/// Indian-grouped currency, e.g. ₹1,12,400.
String money(num n) {
  final neg = n < 0;
  return '${neg ? '-' : ''}₹${_indianGroup(n.abs().round())}';
}

/// A prominent money value with the ₹ symbol slightly de-emphasised (DESIGN.md)
/// and tabular figures, so the digits stay the focus and columns align. Use for
/// totals / KPIs / balances; plain `Text(money(x))` is fine for inline amounts.
class Money extends StatelessWidget {
  final num amount;
  final TextStyle style;
  final Color? color;
  const Money(this.amount, {required this.style, this.color, super.key});
  @override
  Widget build(BuildContext context) {
    final neg = amount < 0;
    final base = style.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]);
    final symbolColor = (color ?? style.color ?? DefaultTextStyle.of(context).style.color)?.withValues(alpha: 0.62);
    return Text.rich(
      TextSpan(
        children: [
          if (neg) TextSpan(text: '-', style: base),
          TextSpan(
            text: '₹',
            style: base.copyWith(color: symbolColor, fontWeight: FontWeight.w600),
          ),
          TextSpan(text: _indianGroup(amount.abs().round()), style: base),
        ],
      ),
    );
  }
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
    return Pill(priorityLabel(L.of(ctx), p), color: c);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(icon != null ? 6 : 9, 3, 9, 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ignore: use_null_aware_elements
          if (icon != null) Icon(icon, size: 12, color: color),
          if (icon != null) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
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
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: bx.muted),
      ),
    );
  }
}

/// One standard confirmation dialog for destructive actions, so every
/// "delete / remove / return" prompt looks and behaves the same (design-system
/// consistency). Returns true only if the user confirms.
Future<bool> confirmDialog(BuildContext context, {required String title, required String message, String confirmLabel = 'Confirm', String cancelLabel = 'Cancel', bool destructive = false}) async {
  final bx = context.bx;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(message, style: const TextStyle(height: 1.4)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: destructive ? FilledButton.styleFrom(backgroundColor: bx.danger) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// A consistent inline error state (mirrors [EmptyState]) for failed loads.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorState({required this.message, this.onRetry, super.key});
  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 40, color: bx.danger),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: bx.muted, height: 1.45),
          ),
          if (onRetry != null) ...[const SizedBox(height: 14), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, size: 18), label: const Text('Retry'))],
        ],
      ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BxText.pageTitle),
                const SizedBox(height: 4),
                Text(subtitle, style: BxText.body.copyWith(color: bx.muted)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
