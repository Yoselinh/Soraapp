import 'package:flutter/material.dart';
import 'sora_colors.dart';

class SoraTheme {
  SoraTheme._();

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: SoraColors.colorScheme,
        scaffoldBackgroundColor: SoraColors.background,
        fontFamily: 'Roboto',

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: SoraColors.background,
          foregroundColor: SoraColors.onBackground,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: SoraColors.onBackground),
        ),

        // BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: SoraColors.onBackground,
          selectedItemColor: SoraColors.primary,
          unselectedItemColor: Color(0xFF8D7060),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),

        // Cards
        cardTheme: CardThemeData(
          color: SoraColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SoraColors.cardBorder, width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // FilledButton
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: SoraColors.primary,
            foregroundColor: SoraColors.onPrimary,
            minimumSize: const Size(64, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
        ),

        // OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: SoraColors.primary,
            side: const BorderSide(color: SoraColors.primary, width: 1.5),
            minimumSize: const Size(64, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: SoraColors.primary,
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: SoraColors.surface,
          selectedColor: SoraColors.primary,
          labelStyle: const TextStyle(color: SoraColors.onBackground, fontSize: 13),
          secondaryLabelStyle: const TextStyle(color: SoraColors.onPrimary, fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: SoraColors.cardBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: SoraColors.cardBorder,
          thickness: 1,
          space: 0,
        ),

        // InputDecoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: SoraColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SoraColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SoraColors.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SoraColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF5D4038)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        // Text
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          headlineLarge: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          titleMedium: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF5D4038),
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            color: Color(0xFF8D7060),
            fontSize: 12,
          ),
          labelLarge: TextStyle(
            color: SoraColors.onBackground,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
