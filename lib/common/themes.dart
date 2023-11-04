import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:place_keeper/common/custom_colors.dart';

final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.nunito(
          color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
      bodyMedium: GoogleFonts.nunito(
          color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
      bodySmall: GoogleFonts.nunito(
          color: Colors.black, fontWeight: FontWeight.w400, fontSize: 15),
      displayLarge: GoogleFonts.nunito(color: Colors.black),
      displayMedium: GoogleFonts.nunito(color: Colors.black),
      displaySmall: GoogleFonts.nunito(color: Colors.black),
      titleLarge: GoogleFonts.nunito(color: Colors.black),
      titleMedium: GoogleFonts.nunito(color: Colors.black),
      titleSmall: GoogleFonts.nunito(color: Colors.black),
      headlineLarge: GoogleFonts.nunito(color: Colors.black),
      headlineMedium: GoogleFonts.nunito(color: Colors.black),
      headlineSmall: GoogleFonts.nunito(color: Colors.black),
      labelLarge:
          GoogleFonts.nunito(color: Colors.black, fontWeight: FontWeight.w500),
      labelMedium:
          GoogleFonts.nunito(color: Colors.black, fontWeight: FontWeight.w500),
      labelSmall:
          GoogleFonts.nunito(color: Colors.black, fontWeight: FontWeight.w500),
    ),
    scaffoldBackgroundColor: CustomColors.surface,
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: CustomColors.indigoPurple,
            textStyle: GoogleFonts.nunito())),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.indigoPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)))),
    appBarTheme: AppBarTheme(
        backgroundColor: CustomColors.surface,
        foregroundColor: Colors.black,
        titleTextStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        elevation: 0),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: CustomColors.indigoPurple,
        selectionColor: CustomColors.indigoPurple.withOpacity(0.3),
        selectionHandleColor: CustomColors.indigoPurple),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.red, dragHandleColor: Colors.blue,  modalBackgroundColor: CustomColors.surface)
);
