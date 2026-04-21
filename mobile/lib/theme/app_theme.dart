import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NovaMartTheme {
  // Colors
  static const Color ink = Color(0xFF0A0A0A);
  static const Color ink2 = Color(0xFF1A1A1A);
  static const Color ink3 = Color(0xFF555555);
  static const Color ink4 = Color(0xFF999999);
  static const Color ink5 = Color(0xFFCCCCCC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color bg = Color(0xFFF9F9F9);
  static const Color bg2 = Color(0xFFF2F2F2);
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderDark = Color(0xFFD0D0D0);
  static const Color green = Color(0xFF1A6B36);
  static const Color greenBg = Color(0xFFF0F7F3);
  static const Color red = Color(0xFFB91C1C);
  static const Color redBg = Color(0xFFFEF2F2);
  static const Color amber = Color(0xFF92400E);
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color blue = Color(0xFF1D4ED8);
  static const Color blueBg = Color(0xFFEFF6FF);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: ink,
        secondary: ink3,
        surface: white,
        error: red,
      ),
      textTheme: GoogleFonts.syneTextTheme().copyWith(
        displayLarge: GoogleFonts.instrumentSerif(
          fontSize: 40, fontWeight: FontWeight.w400, color: ink,
          letterSpacing: -1.5, height: 1.0,
        ),
        displayMedium: GoogleFonts.instrumentSerif(
          fontSize: 32, fontWeight: FontWeight.w400, color: ink,
          letterSpacing: -1.0, height: 1.05,
        ),
        displaySmall: GoogleFonts.instrumentSerif(
          fontSize: 26, fontWeight: FontWeight.w400, color: ink,
          letterSpacing: -0.8, height: 1.1,
        ),
        headlineLarge: GoogleFonts.syne(
          fontSize: 22, fontWeight: FontWeight.w800, color: ink,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.syne(
          fontSize: 18, fontWeight: FontWeight.w700, color: ink,
        ),
        headlineSmall: GoogleFonts.syne(
          fontSize: 15, fontWeight: FontWeight.w700, color: ink,
        ),
        bodyLarge: GoogleFonts.syne(
          fontSize: 15, fontWeight: FontWeight.w400, color: ink2,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.syne(
          fontSize: 13, fontWeight: FontWeight.w400, color: ink3,
          height: 1.6,
        ),
        bodySmall: GoogleFonts.ibmPlexMono(
          fontSize: 11, fontWeight: FontWeight.w400, color: ink4,
          letterSpacing: 0.5,
        ),
        labelLarge: GoogleFonts.syne(
          fontSize: 12, fontWeight: FontWeight.w700, color: ink,
          letterSpacing: 1.2,
        ),
        labelMedium: GoogleFonts.ibmPlexMono(
          fontSize: 10, fontWeight: FontWeight.w500, color: ink4,
          letterSpacing: 1.0,
        ),
        labelSmall: GoogleFonts.ibmPlexMono(
          fontSize: 9, fontWeight: FontWeight.w400, color: ink5,
          letterSpacing: 0.8,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.syne(
          fontSize: 14, fontWeight: FontWeight.w800,
          color: ink, letterSpacing: 1.5,
        ),
        toolbarHeight: 60,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 0,
      ),
      cardTheme: const CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border, width: 1.5),
        ),
      ),
    );
  }
}

// Typography helpers
TextStyle get monoStyle => GoogleFonts.ibmPlexMono(
  fontSize: 11, color: NovaMartTheme.ink4,
  letterSpacing: 0.8, fontWeight: FontWeight.w500,
);

TextStyle get monoStyleDark => GoogleFonts.ibmPlexMono(
  fontSize: 11, color: NovaMartTheme.ink,
  letterSpacing: 0.5, fontWeight: FontWeight.w500,
);

TextStyle get serifLarge => GoogleFonts.instrumentSerif(
  fontSize: 28, color: NovaMartTheme.ink,
  letterSpacing: -0.8, height: 1.05,
);
