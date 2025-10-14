import 'package:flutter/material.dart';

class AppTheme {
  static final _lightInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25.0),
    borderSide: const BorderSide(color: Colors.grey),
  );

  static final _darkInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(25.0),
    borderSide: const BorderSide(color: Colors.white70),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: _lightInputBorder,
        enabledBorder: _lightInputBorder,
        focusedBorder: _lightInputBorder.copyWith(
          borderSide: const BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: _darkInputBorder,
        enabledBorder: _darkInputBorder,
        focusedBorder: _darkInputBorder.copyWith(
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
      ),
    );
  }
}