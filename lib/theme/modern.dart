import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension MetaStyles on TextTheme {
  TextStyle get metaText => GoogleFonts.sourceSansPro(fontSize: 16);
}

class ModernTheme {
  static ThemeData get darkTheme {
    const _orangePrimaryValue = 0xFFF55951;

    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF543C52),
        secondary: Color(_orangePrimaryValue),
        secondaryVariant: Color(0xFFF22C22),
      ),
      primaryColor: const Color(0xFF543C52),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // scaffoldBackgroundColor: Color(0xFF361D32),
      scaffoldBackgroundColor: const Color(0xFF222222),
      fontFamily: GoogleFonts.sourceSansPro().fontFamily,
      textTheme: TextTheme(
        headline1: GoogleFonts.poppins(
          fontSize: 50,
          height: 1.1,
          color: Colors.white,
        ),
        headline2: GoogleFonts.poppins(
          fontSize: 36,
          height: 1.1,
          color: Colors.white,
        ),
        headline3: GoogleFonts.poppins(
          fontSize: 30,
          height: 1.0,
          color: Colors.grey.shade300,
        ),
        bodyText1: GoogleFonts.sourceSansPro(
          color: const Color(0xFFEEEEEE),
          height: 1.5,
          fontSize: 18,
        ),
        bodyText2: GoogleFonts.sourceSansPro(
          color: const Color(0xFFEEEEEE),
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        buttonColor: Colors.blue,
      ),
    );
  }
}
