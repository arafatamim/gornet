import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension MetaStyles on TextTheme {
  TextStyle get metaText => GoogleFonts.sourceSansPro(fontSize: 16);
}

class ModernTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      primarySwatch: Colors.orange,
      accentColor: Colors.orange,
      scaffoldBackgroundColor: Colors.grey.shade900,
      fontFamily: GoogleFonts.sourceSansPro().fontFamily,
      textTheme: TextTheme(
        headline1: GoogleFonts.oswald(
          fontSize: 50,
          height: 1.1,
          color: Colors.white,
        ),
        headline2: GoogleFonts.oswald(
          fontSize: 40,
          height: 1.1,
          color: Colors.white,
        ),
        bodyText1: GoogleFonts.sourceSansPro(
          color: Color(0xFFEEEEEE),
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
