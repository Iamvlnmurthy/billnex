import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../theme/app_theme.dart';

/// Theme-aware business-type icon (Codex biztype art) with a Material fallback.
class BizIcon extends StatelessWidget {
  final String bizKey;
  final IconData fallback;
  final double size;
  const BizIcon({required this.bizKey, required this.fallback, this.size = 24, super.key});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final slug = kBizIconSlug[bizKey];
    if (slug == null) return Icon(fallback, size: size, color: bx.brand);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      'assets/biztypes/${dark ? 'dark' : 'light'}/$slug@2x.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (c, e, s) => Icon(fallback, size: size, color: bx.brand),
    );
  }
}

/// Renders a Codex-generated illustration, theme-aware (light/dark folder).
class BxIllustration extends StatelessWidget {
  final String name; // e.g. 'empty-no-products', 'status-success'
  final double size;
  const BxIllustration(this.name, {this.size = 150, super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      'assets/illustrations/${dark ? 'dark' : 'light'}/$name@1x.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Graceful fallback if an asset is missing.
      errorBuilder: (c, e, s) => Icon(Icons.inventory_2_outlined, size: size * 0.45, color: context.bx.faint),
    );
  }
}

/// A polished empty-state: illustration + title + subtitle + optional action.
class EmptyState extends StatelessWidget {
  final String illustration;
  final String title;
  final String subtitle;
  final Widget? action;
  final double illustrationSize;
  const EmptyState({
    required this.illustration,
    required this.title,
    required this.subtitle,
    this.action,
    this.illustrationSize = 150,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        BxIllustration(illustration, size: illustrationSize),
        const SizedBox(height: 18),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, color: bx.muted, height: 1.45)),
        if (action != null) ...[const SizedBox(height: 18), action!],
      ]),
    );
  }
}
