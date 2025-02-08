import 'package:flutter/material.dart';
import '../constants/style.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData getLightTheme(BuildContext context) {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: Colors.black),
      canvasColor: Colors.grey[200],
      primaryColor: primaryColor,
      cardColor: Colors.white,
    );
  }

  ThemeData getDarkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          .apply(bodyColor: Colors.white),
      canvasColor: secondaryColor,
      primaryColor: primaryColor,
      cardColor: secondaryColor,
    );
  }
}
