import 'package:flutter/material.dart';

/// BillNex design system — adopted from the Stitch "Modern Corporate" spec
/// (stitch_billnex_design_system_pos_interface/billnex/DESIGN.md).
/// Deep Navy + Primary Blue, cool grey-blue surfaces, white cards with soft
/// ambient shadow, Inter-style type, 8pt grid, green PAID / amber PENDING.
class Bx {
  // Premium Command Center palette: vivid cobalt on a sober navy foundation.
  static const primaryLight = Color(0xFF1677FF);
  static const primaryDeep = Color(0xFF075ED8);
  static const primaryDark = Color(0xFF69A4FF);

  static const radius = 18.0;
  static const radiusSm = 12.0;

  // Card ambient shadow from the spec.
  static const cardShadow = [
    BoxShadow(color: Color(0x0F0A2540), blurRadius: 8, spreadRadius: -3, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x1A0A2540), blurRadius: 24, spreadRadius: -8, offset: Offset(0, 16)),
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
    surface2: Color(0xFFF1F6FD),
    muted: Color(0xFF42526A),
    faint: Color(0xFF718096),
    border: Color(0xFFD7E2F0),
    trustOnline: Color(0xFF12B76A),
    cardShadow: Bx.cardShadow,
  );

  static const dark = BxColors(
    brand: Color(0xFFEAF2FF),
    brand2: Color(0xFF69A4FF),
    accent: Color(0xFF3988FF),
    onAccent: Colors.white,
    pos: Color(0xFF35D07F),
    posBg: Color(0xFF102F28),
    warn: Color(0xFFFFC46B),
    warnBg: Color(0xFF342817),
    danger: Color(0xFFFF746C),
    dangerBg: Color(0xFF351C22),
    surface2: Color(0xFF10243D),
    muted: Color(0xFFA9B8CC),
    faint: Color(0xFF74869E),
    border: Color(0xFF27415F),
    trustOnline: Color(0xFF35D07F),
    cardShadow: [BoxShadow(color: Color(0x66030B16), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 18))],
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

  // Refined ramp: weight carries hierarchy without shouting. w800 is reserved for
  // hero *numbers* (money) where heft aids scanning; titles are w700, labels w600,
  // body regular. Calmer than the previous all-w800 look.

  /// Big screen title (dashboard/section pages). 23/700.
  static const pageTitle = TextStyle(fontSize: 23, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.18);

  /// Section heading within a page. 17/700.
  static const section = TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.25);

  /// Card / list-row title. 15/600.
  static const cardTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1);

  /// Prominent money value (totals, KPIs, balances). Tabular figures. 22/700.
  static const value = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, fontFeatures: _tab);

  /// Hero money value (Collect total, today's sales). Tabular figures. 29/800.
  static const valueHero = TextStyle(fontSize: 29, fontWeight: FontWeight.w800, letterSpacing: -0.7, fontFeatures: _tab);

  /// Body text.
  static const body = TextStyle(fontSize: 14, height: 1.45, letterSpacing: 0.05);

  /// Secondary / supporting text.
  static const supporting = TextStyle(fontSize: 12.5, height: 1.45, letterSpacing: 0.05);

  /// Uppercase metadata label. 11.5/600 +0.5 tracking.
  static const meta = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.5);
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
      // Primary UI typeface: Plus Jakarta Sans (bundled). Inter is the Latin
      // fallback; Devanagari/Telugu fall through to the system Noto fonts.
      fontFamily: 'PlusJakartaSans',
      fontFamilyFallback: const ['Inter'],
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
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(color: scheme.onSurface, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.25),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ext.accent, width: 1.5),
        ),
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
        elevation: 0,
        indicatorColor: ext.accent.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) =>
              TextStyle(fontSize: 11.5, fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500, color: states.contains(WidgetState.selected) ? ext.accent : ext.muted),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        foregroundColor: scheme.onPrimary,
        backgroundColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ext.surface2,
        selectedColor: ext.accent.withValues(alpha: 0.18),
        side: BorderSide(color: ext.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(color: ext.muted, fontWeight: FontWeight.w700),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dividerTheme: DividerThemeData(color: ext.border, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ThemeData light() {
    const ext = BxColors.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: Bx.primaryDeep,
    ).copyWith(primary: Bx.primaryLight, onPrimary: Colors.white, surface: Colors.white, surfaceContainerLowest: const Color(0xFFF3F7FC), onSurface: const Color(0xFF102037), outline: ext.border);
    return _base(Brightness.light, ext, scheme);
  }

  static ThemeData dark() {
    const ext = BxColors.dark;
    final scheme = ColorScheme.fromSeed(seedColor: Bx.primaryLight, brightness: Brightness.dark).copyWith(
      primary: const Color(0xFF3988FF),
      onPrimary: Colors.white,
      surface: const Color(0xFF0E2036),
      surfaceContainerLowest: const Color(0xFF071426),
      onSurface: const Color(0xFFF3F7FF),
      outline: ext.border,
    );
    return _base(Brightness.dark, ext, scheme);
  }
}
