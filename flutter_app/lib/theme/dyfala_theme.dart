import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class DyfalaPalette {
  static const cream = Color(0xFFFFF8EC);
  static const creamDeep = Color(0xFFF4E8D2);
  static const red = Color(0xFFE9243F);
  static const redDark = Color(0xFFC81B34);
  static const green = Color(0xFF0C6B4D);
  static const greenDark = Color(0xFF064A38);
  static const greenLight = Color(0xFF2A9B6C);
  static const yellow = Color(0xFFF4B63F);
  static const navy = Color(0xFF071A27);
  static const inkSoft = Color(0xFF536065);
  static const tileBorder = Color(0xFFD8CCB8);
  static const absent = Color(0xFF7F8789);
  static const white = Color(0xFFFFFDF8);
}

abstract final class DyfalaSizes {
  static const double pagePadding = 20;
  static const double cardRadius = 24;
  static const double keyRadius = 10;
  static const double tileRadius = 9;
}

ThemeData buildDyfalaTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: DyfalaPalette.red,
    brightness: Brightness.light,
    primary: DyfalaPalette.red,
    secondary: DyfalaPalette.green,
    surface: DyfalaPalette.cream,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: DyfalaPalette.cream,
  );

  return base.copyWith(
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.fredoka(
        color: DyfalaPalette.navy,
        fontSize: 42,
        height: 1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.4,
      ),
      headlineMedium: GoogleFonts.fredoka(
        color: DyfalaPalette.navy,
        fontSize: 32,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      ),
      titleLarge: GoogleFonts.fredoka(
        color: DyfalaPalette.navy,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.nunitoSans(
        color: DyfalaPalette.navy,
        fontSize: 17,
        height: 1.35,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: GoogleFonts.nunitoSans(
        color: DyfalaPalette.inkSoft,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w700,
      ),
      labelLarge: GoogleFonts.nunitoSans(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
