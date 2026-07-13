import 'package:flutter/material.dart';

/// BillNex design system — adopted from the Stitch "Modern Corporate" spec
/// (stitch_billnex_design_system_pos_interface/billnex/DESIGN.md).
/// Deep Navy + Primary Blue, cool grey-blue surfaces, white cards with soft
/// ambient shadow, Inter-style type, 8pt grid, green PAID / amber PENDING.
class Bx {
  // Primary blue (interactive) + deep navy-blue
  static const primaryLight = Color(0xFF146CFF);
  static const primaryDeep = Color(0xFF0055D1);
  static const primaryDark = Color(0xFF5B8CFF);

  static const radius = 16.0;
  static const radiusSm = 8.0;

  // Card ambient shadow from the spec.
  static const cardShadow = [
    BoxShadow(color: Color(0x0A101828), blurRadius: 6, spreadRadius: -2, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x14101828), blurRadius: 16, spreadRadius: -4, offset: Offset(0, 12)),
  ];
}

/// Extra semantic colors beyond the stock [ColorScheme].
@immutable
class BxColors extends ThemeExtension<BxColors> {
  final Color brand; // deep navy-blue (logo, headings accents)
  final Color brand2; // gradient partner
  final Color accent; // interactive blue
  final Color onAccent;
  final Color pos; // money-positive / PAID (green)
  final Color posBg;
  final Color warn; // PENDING / low-stock (amber)
  final Color warnBg;
  final Color danger;
  final Color dangerBg;
  final Color surface2;
  final Color muted;
  final Color faint;
  final Color border;
  final Color trustOnline;
  final List<BoxShadow> cardShadow;

  const BxColors({
    required this.brand,
    required this.brand2,
    required this.accent,
    required this.onAccent,
    required this.pos,
    required this.posBg,
    required this.warn,
    required this.warnBg,
    required this.danger,
    required this.dangerBg,
    required this.surface2,
    required this.muted,
    required this.faint,
    required this.border,
    required this.trustOnline,
    required this.cardShadow,
  });

  static const light = BxColors(
    brand: Bx.primaryDeep,
    brand2: Bx.primaryLight,
    accent: Bx.primaryLight,
    onAccent: Colors.white,
    pos: Color(0xFF12B76A),
    posBg: Color(0xFFE6F6EE),
    warn: Color(0xFF9A4400),
    warnBg: Color(0xFFFBEEDD),
    danger: Color(0xFFBA1A1A),
    dangerBg: Color(0xFFFDECEC),
    surface2: Color(0xFFF0F3FF),
    muted: Color(0xFF424655),
    faint: Color(0xFF727687),
    border: Color(0xFFC2C6D8),
    trustOnline: Color(0xFF12B76A),
    cardShadow: Bx.cardShadow,
  );

  static const dark = BxColors(
    brand: Color(0xFFB2C5FF),
    brand2: Bx.primaryLight,
    accent: Color(0xFF5B8CFF),
    onAccent: Color(0xFF06122B),
    pos: Color(0xFF3DD68C),
    posBg: Color(0xFF13291F),
    warn: Color(0xFFFFB68E),
    warnBg: Color(0xFF2E2013),
    danger: Color(0xFFFFB4AB),
    dangerBg: Color(0xFF2C1513),
    surface2: Color(0xFF141D30),
    muted: Color(0xFFAAB3C5),
    faint: Color(0xFF727687),
    border: Color(0xFF2A3448),
    trustOnline: Color(0xFF3DD68C),
    cardShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 18, spreadRadius: -6, offset: Offset(0, 10))],
  );

  @override
  BxColors copyWith({
    Color? brand,
    Color? brand2,
    Color? accent,
    Color? onAccent,
    Color? pos,
    Color? posBg,
    Color? warn,
    Color? warnBg,
    Color? danger,
    Color? dangerBg,
    Color? surface2,
    Color? muted,
    Color? faint,
    Color? border,
    Color? trustOnline,
    List<BoxShadow>? cardShadow,
  }) => BxColors(
    brand: brand ?? this.brand,
    brand2: brand2 ?? this.brand2,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    pos: pos ?? this.pos,
    posBg: posBg ?? this.posBg,
    warn: warn ?? this.warn,
    warnBg: warnBg ?? this.warnBg,
    danger: danger ?? this.danger,
    dangerBg: dangerBg ?? this.dangerBg,
    surface2: surface2 ?? this.surface2,
    muted: muted ?? this.muted,
    faint: faint ?? this.faint,
    border: border ?? this.border,
    trustOnline: trustOnline ?? this.trustOnline,
    cardShadow: cardShadow ?? this.cardShadow,
  );

  @override
  BxColors lerp(BxColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return BxColors(
      brand: c(brand, other.brand),
      brand2: c(brand2, other.brand2),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      pos: c(pos, other.pos),
      posBg: c(posBg, other.posBg),
      warn: c(warn, other.warn),
      warnBg: c(warnBg, other.warnBg),
      danger: c(danger, other.danger),
      dangerBg: c(dangerBg, other.dangerBg),
      surface2: c(surface2, other.surface2),
      muted: c(muted, other.muted),
      faint: c(faint, other.faint),
      border: c(border, other.border),
      trustOnline: c(trustOnline, other.trustOnline),
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
    );
  }
}

extension BxContext on BuildContext {
  BxColors get bx => Theme.of(this).extension<BxColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

/// Design-system type scale (from DESIGN.md) — one source of truth for
/// headings/values so screens stop hand-picking arbitrary font sizes. All
/// numeric styles use tabular figures so amounts line up in columns.
class BxText {
  static const _tab = [FontFeature.tabularFigures()];

  /// Big screen title (dashboard/section pages). Mobile page-title, 24/800.
  static const pageTitle = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.15);

  /// Section heading within a page. 20/700.
  static const section = TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3);

  /// Card / list-row title. 16/600.
  static const cardTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  /// Prominent money value (totals, KPIs, balances). Tabular figures.
  static const value = TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, fontFeatures: _tab);

  /// Hero money value (Collect total, today's sales). Tabular figures.
  static const valueHero = TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1, fontFeatures: _tab);

  /// Body text.
  static const body = TextStyle(fontSize: 14, height: 1.4);

  /// Secondary / supporting text.
  static const supporting = TextStyle(fontSize: 12.5, height: 1.4);

  /// Uppercase metadata label. 12/700 +0.4 tracking.
  static const meta = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.4);
}

class AppTheme {
  /// Applies tabular figures to every slot of a [TextTheme] so digits are
  /// monospaced (amount columns line up). Inline Text styles inherit it.
  static TextTheme _tabularFigures(TextTheme t) {
    const feat = [FontFeature.tabularFigures()];
    TextStyle? f(TextStyle? s) => s?.copyWith(fontFeatures: feat);
    return t.copyWith(
      displayLarge: f(t.displayLarge),
      displayMedium: f(t.displayMedium),
      displaySmall: f(t.displaySmall),
      headlineLarge: f(t.headlineLarge),
      headlineMedium: f(t.headlineMedium),
      headlineSmall: f(t.headlineSmall),
      titleLarge: f(t.titleLarge),
      titleMedium: f(t.titleMedium),
      titleSmall: f(t.titleSmall),
      bodyLarge: f(t.bodyLarge),
      bodyMedium: f(t.bodyMedium),
      bodySmall: f(t.bodySmall),
      labelLarge: f(t.labelLarge),
      labelMedium: f(t.labelMedium),
      labelSmall: f(t.labelSmall),
    );
  }

  static ThemeData _base(Brightness b, BxColors ext, ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      extensions: [ext],
      fontFamily: 'Inter', // the design-system typeface (bundled in assets/fonts)
      // Tabular figures everywhere so ₹ amounts and quantities align in columns.
      // Text with an inline style inherits this (merge keeps ambient fontFeatures).
      textTheme: _tabularFigures(ThemeData(brightness: b, useMaterial3: true).textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Bx.radius),
          side: BorderSide(color: ext.border),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Bx.radiusSm)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(0, 44),
          side: BorderSide(color: ext.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Bx.radiusSm)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: ext.accent.withValues(alpha: 0.14),
        labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ext.muted)),
      ),
      dividerTheme: DividerThemeData(color: ext.border, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ThemeData light() {
    const ext = BxColors.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: Bx.primaryDeep,
    ).copyWith(primary: Bx.primaryLight, onPrimary: Colors.white, surface: Colors.white, surfaceContainerLowest: const Color(0xFFF4F6FC), onSurface: const Color(0xFF111C2D), outline: ext.border);
    return _base(Brightness.light, ext, scheme);
  }

  static ThemeData dark() {
    const ext = BxColors.dark;
    final scheme = ColorScheme.fromSeed(seedColor: Bx.primaryLight, brightness: Brightness.dark).copyWith(
      primary: const Color(0xFF4D82FF),
      onPrimary: const Color(0xFF06122B),
      surface: const Color(0xFF141D30),
      surfaceContainerLowest: const Color(0xFF0B1220),
      onSurface: const Color(0xFFECF0FF),
      outline: ext.border,
    );
    return _base(Brightness.dark, ext, scheme);
  }
}
