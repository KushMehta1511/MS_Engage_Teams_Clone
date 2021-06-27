import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  bool get isDarkMode => themeMode == ThemeMode.dark;
}

class MyThemes {
  static final darkTheme = ThemeData(
    primaryColor: Color(0xFF534DD6),
    accentColor: Color(0xFF534DD6),
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: ColorScheme.dark(),
  );
  static final lightTheme = ThemeData(
      primaryColor: Color(0xFF534DD6),
      accentColor: Color(0xFF534DD6),
      buttonColor: Color(0xFF534DD6),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light());
}
