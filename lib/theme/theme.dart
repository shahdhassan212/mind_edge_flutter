import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class AppTheme {
  AppTheme._();

  static TextStyle syne(
          {double size = 14,
          FontWeight weight = FontWeight.w400,
          Color? color,
          double? letterSpacing,
          double? height}) =>
      GoogleFonts.syne(
          fontSize: size,
          fontWeight: weight,
          color: color ?? AppColors.white,
          letterSpacing: letterSpacing,
          height: height);

  static TextStyle cormorant(
          {double size = 14,
          FontWeight weight = FontWeight.w300,
          Color? color,
          bool italic = false,
          double? letterSpacing,
          double? height}) =>
      GoogleFonts.cormorantGaramond(
          fontSize: size,
          fontWeight: weight,
          color: color ?? AppColors.white,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          letterSpacing: letterSpacing,
          height: height);

  static TextStyle dmSans(
          {double size = 13,
          FontWeight weight = FontWeight.w300,
          Color? color,
          double? letterSpacing,
          double? height}) =>
      GoogleFonts.dmSans(
          fontSize: size,
          fontWeight: weight,
          color: color ?? AppColors.white,
          letterSpacing: letterSpacing,
          height: height);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFDFAF4),
        colorScheme: ColorScheme.light(
          primary: AppColors.cocoa,
          secondary: AppColors.gold,
          surface: const Color(0xFFFDFAF4),
          error: const Color(0xFFE05252),
        ),
        fontFamily: GoogleFonts.dmSans().fontFamily,
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          bodyMedium: GoogleFonts.dmSans(color: AppColors.cocoaDeep),
        ),
        inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.cocoaDeep,
        ),
      );
}
