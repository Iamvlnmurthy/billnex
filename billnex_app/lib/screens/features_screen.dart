import 'package:flutter/material.dart';
import '../data/catalog.dart';
import '../data/catalog_i18n.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../l10n/app_localizations.dart';

class FeaturesScreen extends StatelessWidget {
  final AppState state;
  const FeaturesScreen({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final biz = state.business!;
    final l = L.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 100),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              PageHeader(l.navFeatures, l.featuresSubtitle(biz.name)),
              for (final cat in kCategories) ...[_CategoryCard(state: state, cat: cat), const SizedBox(height: 16)],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AppState state;
  final FeatureCategory cat;
  const _CategoryCard({required this.state, required this.cat});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final caps = kCapabilities.where((c) => c.category == cat.key).toList();
    final on = state.enabledInCategory(cat.key);
    // "Enable/Disable all" only toggles unlockable caps, so base its label on
    // those (a locked Pro cap would otherwise pin the label to "Enable all").
    final unlockable = caps.where((c) => !state.isLocked(c.key)).toList();
    final allOn = unlockable.isNotEmpty && unlockable.every((c) => state.isOn(c.key));

    return Card(
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: bx.brand.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(9)),
                  child: Icon(cat.icon, size: 19, color: bx.brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryName(l, cat.key), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(l.featuresEnabledCount(on, caps.length), style: TextStyle(fontSize: 12, color: bx.muted)),
                    ],
                  ),
                ),
                TextButton(onPressed: () => state.toggleCategory(cat.key), child: Text(allOn ? l.disableAll : l.enableAll)),
              ],
            ),
          ),
          for (final cap in caps) _FeatureRow(state: state, cap: cap),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final AppState state;
  final Capability cap;
  const _FeatureRow({required this.state, required this.cap});

  @override
  Widget build(BuildContext context) {
    final bx = context.bx;
    final l = L.of(context);
    final locked = state.isLocked(cap.key);
    final preset = state.isPreset(cap.key);

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: bx.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(capabilityName(l, cap.key), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Pill.priority(cap.priority, context),
                    if (cap.pro) Pill(l.proBadge, color: bx.accent),
                    if (preset) Pill(l.presetBadge, color: bx.pos, icon: Icons.check),
                  ],
                ),
                const SizedBox(height: 2),
                Text(capabilityDesc(l, cap.key), style: TextStyle(fontSize: 12, color: bx.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (locked)
            Row(
              children: [
                Icon(Icons.lock_outline, size: 15, color: bx.accent),
                const SizedBox(width: 5),
                Text(
                  l.proPlan,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: bx.accent),
                ),
              ],
            )
          else
            Switch(value: state.isOn(cap.key), onChanged: (v) => state.setFlag(cap.key, v)),
        ],
      ),
    );
  }
}
