import 'package:flutter/material.dart';

/// Paleta de colores SORA
/// Fondo: crema #F0E8DC
/// Texto/Nav: marrón oscuro #2B1C14
/// Acento: terracota #B04F36
/// Tarjetas: blanco roto #FAF6F1
class SoraColors {
  SoraColors._();

  static const Color background = Color(0xFFF0E8DC);
  static const Color surface = Color(0xFFFAF6F1);
  static const Color cardBorder = Color(0xFFE2D5C8);
  static const Color onBackground = Color(0xFF2B1C14);
  static const Color primary = Color(0xFFB04F36);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF7A3E27);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color tertiary = Color(0xFFD4845A);
  static const Color outline = Color(0xFFBFAA98);
  static const Color disabled = Color(0xFFCFC0B0);
  static const Color error = Color(0xFFBA1A1A);

  static ColorScheme get colorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: Color(0xFFFFDAD2),
        onPrimaryContainer: Color(0xFF3E0600),
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: Color(0xFFFFDBCF),
        onSecondaryContainer: Color(0xFF2C0F06),
        tertiary: tertiary,
        onTertiary: onPrimary,
        tertiaryContainer: Color(0xFFFFDBCC),
        onTertiaryContainer: Color(0xFF3A1400),
        error: error,
        onError: onPrimary,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: surface,
        onSurface: onBackground,
        surfaceContainerHighest: Color(0xFFEDE0D8),
        onSurfaceVariant: Color(0xFF5D4038),
        outline: outline,
        outlineVariant: Color(0xFFD8C5BB),
        shadow: Color(0x1A2B1C14),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF2B1C14),
        onInverseSurface: Color(0xFFF5EDE8),
        inversePrimary: Color(0xFFFFB4A4),
      );
}
