import 'package:flutter/material.dart';

const Color loopinPrimaryColor = Color(0xFF21c3c5);
const Color backgroundColor = Colors.white;
const Color textColor = Colors.black;
const Color mutedTextColor = Colors.black54;

final ButtonStyle loopinButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: loopinPrimaryColor,
  foregroundColor: Colors.white,
  minimumSize: const Size.fromHeight(50),
  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
);

final ThemeData loopinTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: backgroundColor,
  primaryColor: loopinPrimaryColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: loopinPrimaryColor,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(style: loopinButtonStyle),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: loopinPrimaryColor,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(color: mutedTextColor),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: mutedTextColor),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: loopinPrimaryColor),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: loopinPrimaryColor,
    behavior: SnackBarBehavior.floating,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: textColor,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(color: textColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
).copyWith(
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: loopinPrimaryColor,
    selectionColor: Color(0x5521c3c5),
    selectionHandleColor: loopinPrimaryColor,
  ),
);
