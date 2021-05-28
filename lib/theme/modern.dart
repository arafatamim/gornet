import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension MetaStyles on TextTheme {
  TextStyle get metaText => GoogleFonts.sourceSansPro(fontSize: 16);
}

class ModernTheme {
  static ThemeData get darkTheme {
    const _orangePrimaryValue = 0xFFF55951;

    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF543C52),
        secondary: Color(_orangePrimaryValue),
      ),
      primaryColor: Color(0xFF543C52),
      // primarySwatch: MaterialColor(
      //   _orangePrimaryValue,
      //   <int, Color>{
      //     50: Color(0xFFFFF8E1),
      //     100: Color(0xFFFFECB3),
      //     200: Color(0xFFFFE082),
      //     300: Color(0xFFFFD54F),
      //     400: Color(0xFFFFCA28),
      //     500: Color(_orangePrimaryValue),
      //     600: Color(0xFFFFB300),
      //     700: Color(0xFFFFA000),
      //     800: Color(0xFFFF8F00),
      //     900: Color(0xFFFF6F00),
      //   },
      // ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // scaffoldBackgroundColor: Color(0xFF361D32),
      scaffoldBackgroundColor: Color(0xFF222222),
      fontFamily: GoogleFonts.sourceSansPro().fontFamily,
      textTheme: TextTheme(
        headline1: GoogleFonts.poppins(
          fontSize: 50,
          height: 1.1,
          color: Colors.white,
        ),
        headline2: GoogleFonts.poppins(
          fontSize: 40,
          height: 1.1,
          color: Colors.white,
        ),
        bodyText1: GoogleFonts.sourceSansPro(
          color: Color(0xFFEEEEEE),
          height: 1.5,
          fontSize: 18,
        ),
        bodyText2: GoogleFonts.sourceSansPro(
          color: Color(0xFFEEEEEE),
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
