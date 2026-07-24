// Tesserotto · Soft & Warm design system
// Single source of truth for colour, type, spacing, radii, motion and shadow.
// Genre: soft · Paper: warm cream · Accent: terracotta-amber
// Display: Fraunces (soft serif) · Body/UI: DM Sans

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Spacing — 4pt scale
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

// ─────────────────────────────────────────────────────────────────────────────
// Radii — one coherent family
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;
}

// ─────────────────────────────────────────────────────────────────────────────
// Motion — no bounce, no overshoot
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}

abstract class AppCurves {
  static const Curve out = Curves.easeOutCubic;
  static const Curve inOut = Curves.easeInOutCubic;
}

// ─────────────────────────────────────────────────────────────────────────────
// Semantic palette — carried as a ThemeExtension so both light & dark share
// the same names. Screens read it via context.palette.
// ─────────────────────────────────────────────────────────────────────────────
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color paper; // scaffold background
  final Color surface; // elevated cards / sheets / app bar
  final Color surfaceMuted; // input fills, chips, inert containers
  final Color ink; // primary text / icons
  final Color inkSoft; // secondary text
  final Color inkFaint; // tertiary text / placeholders
  final Color accent; // primary brand
  final Color accentStrong; // pressed / active
  final Color accentSoft; // tinted background behind accent content
  final Color onAccent; // text/icon on accent fills
  final Color hairline; // borders / dividers
  final Color star; // favourite highlight
  final Color danger; // destructive
  final Color shadow; // shadow colour

  const AppPalette({
    required this.paper,
    required this.surface,
    required this.surfaceMuted,
    required this.ink,
    required this.inkSoft,
    required this.inkFaint,
    required this.accent,
    required this.accentStrong,
    required this.accentSoft,
    required this.onAccent,
    required this.hairline,
    required this.star,
    required this.danger,
    required this.shadow,
  });

  static const light = AppPalette(
    paper: Color(0xFFFAF6F0),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF0E9DF),
    ink: Color(0xFF2A251E),
    inkSoft: Color(0xFF6F675B),
    inkFaint: Color(0xFFA79E90),
    accent: Color(0xFFB4682A),
    accentStrong: Color(0xFF96531D),
    accentSoft: Color(0xFFF3E6D6),
    onAccent: Color(0xFFFFFFFF),
    hairline: Color(0xFFE9E0D4),
    star: Color(0xFFDFA12C),
    danger: Color(0xFFB84A3B),
    shadow: Color(0x1A2A251E),
  );

  static const dark = AppPalette(
    paper: Color(0xFF17140F),
    surface: Color(0xFF221D16),
    surfaceMuted: Color(0xFF2C261D),
    ink: Color(0xFFF3ECDF),
    inkSoft: Color(0xFFB3A794),
    inkFaint: Color(0xFF7C7263),
    accent: Color(0xFFE0904A),
    accentStrong: Color(0xFFC9793A),
    accentSoft: Color(0xFF33281B),
    onAccent: Color(0xFF241505),
    hairline: Color(0xFF352E24),
    star: Color(0xFFE9B24A),
    danger: Color(0xFFE0776A),
    shadow: Color(0x40000000),
  );

  @override
  AppPalette copyWith({
    Color? paper,
    Color? surface,
    Color? surfaceMuted,
    Color? ink,
    Color? inkSoft,
    Color? inkFaint,
    Color? accent,
    Color? accentStrong,
    Color? accentSoft,
    Color? onAccent,
    Color? hairline,
    Color? star,
    Color? danger,
    Color? shadow,
  }) {
    return AppPalette(
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkFaint: inkFaint ?? this.inkFaint,
      accent: accent ?? this.accent,
      accentStrong: accentStrong ?? this.accentStrong,
      accentSoft: accentSoft ?? this.accentSoft,
      onAccent: onAccent ?? this.onAccent,
      hairline: hairline ?? this.hairline,
      star: star ?? this.star,
      danger: danger ?? this.danger,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      paper: Color.lerp(paper, other.paper, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      star: Color.lerp(star, other.star, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenient access — context.palette / context.text
// ─────────────────────────────────────────────────────────────────────────────
extension AppThemeContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// ─────────────────────────────────────────────────────────────────────────────
// Soft, warm-tinted shadows — replaces Material's flat grey elevation.
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppShadow {
  static List<BoxShadow> soft(AppPalette p) => [
        BoxShadow(
          color: p.shadow,
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -6,
        ),
      ];

  static List<BoxShadow> subtle(AppPalette p) => [
        BoxShadow(
          color: p.shadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  /// Coloured lift used under wallet cards — tinted by the card's own colour.
  static List<BoxShadow> tinted(Color color, {bool dark = false}) => [
        BoxShadow(
          color: color.withOpacity(dark ? 0.30 : 0.22),
          blurRadius: 20,
          offset: const Offset(0, 12),
          spreadRadius: -8,
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme assembly
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppPalette.light);
  static ThemeData dark() => _build(Brightness.dark, AppPalette.dark);

  static TextTheme _textTheme(AppPalette p) {
    // Display / headline / large title → Fraunces (soft serif, warm).
    // Titles / body / labels → Manrope (modern geometric sans).
    final display = GoogleFonts.fraunces(
      color: p.ink,
      fontWeight: FontWeight.w600,
      height: 1.1,
    );
    final body = GoogleFonts.manrope(color: p.ink, height: 1.4);

    return TextTheme(
      displayLarge: display.copyWith(fontSize: 40, letterSpacing: -0.5),
      displayMedium: display.copyWith(fontSize: 32, letterSpacing: -0.4),
      displaySmall: display.copyWith(fontSize: 28, letterSpacing: -0.3),
      headlineLarge: display.copyWith(fontSize: 26, letterSpacing: -0.3),
      headlineMedium: display.copyWith(fontSize: 23, letterSpacing: -0.2),
      headlineSmall: display.copyWith(fontSize: 20, letterSpacing: -0.2),
      titleLarge: display.copyWith(fontSize: 21, letterSpacing: -0.2),
      titleMedium:
          body.copyWith(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
      titleSmall:
          body.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: body.copyWith(fontSize: 16),
      bodyMedium: body.copyWith(fontSize: 14, color: p.inkSoft),
      bodySmall: body.copyWith(fontSize: 12.5, color: p.inkSoft),
      labelLarge:
          body.copyWith(fontSize: 15, fontWeight: FontWeight.w700, height: 1.1),
      labelMedium:
          body.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.1),
      labelSmall: body.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.1,
          color: p.inkSoft),
    );
  }

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: brightness,
    ).copyWith(
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      surface: p.surface,
      onSurface: p.ink,
      surfaceContainerHighest: p.surfaceMuted,
      onSurfaceVariant: p.inkSoft,
      outline: p.hairline,
      outlineVariant: p.hairline,
      error: p.danger,
    );

    final textTheme = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.paper,
      canvasColor: p.paper,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      extensions: [p],

      appBarTheme: AppBarTheme(
        backgroundColor: p.paper,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: p.ink),
      ),

      dividerTheme: DividerThemeData(
        color: p.hairline,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: p.ink),

      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: p.hairline),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceMuted,
        hintStyle: textTheme.bodyLarge?.copyWith(color: p.inkFaint),
        labelStyle: textTheme.bodyLarge?.copyWith(color: p.inkSoft),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: p.accent),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: p.danger, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          disabledBackgroundColor: p.surfaceMuted,
          disabledForegroundColor: p.inkFaint,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.surfaceMuted,
          foregroundColor: p.ink,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: p.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: p.paper),
        actionTextColor: p.accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: p.inkSoft),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: p.hairline),
        ),
        textStyle: textTheme.bodyLarge,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: p.inkSoft,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onAccent : p.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.surfaceMuted,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.hairline,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceMuted,
        side: BorderSide(color: p.hairline),
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: p.paper,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.horizontal(right: Radius.circular(AppRadius.xxl)),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
    );
  }
}
