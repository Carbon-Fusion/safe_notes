import 'package:flutter/material.dart';
import 'package:safe_notes/databaseAndStorage/preference_storage_and_state_controls.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = AppSecurePreferencesStorage.getIsThemeDark()
      ? ThemeMode.dark
      : ThemeMode.light; //ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    AppSecurePreferencesStorage.setIsThemeDark(isOn);
    notifyListeners();
  }
}

class AppThemes {
  static final darkTheme = ThemeData(
    primaryColor: Colors.black,
    brightness: Brightness.dark,
    dividerColor: Colors.black12,
    appBarTheme: AppBarTheme(
      //color: Color.fromRGBO(0, 265, 45, 50)
      color: Colors.blueGrey.shade800,
    ),
    scaffoldBackgroundColor: Colors.blueGrey.shade900,
    floatingActionButtonTheme:
        FloatingActionButtonThemeData(backgroundColor: Colors.grey),
    colorScheme: ColorScheme.dark(primary: Colors.blue)
        .copyWith(
            primaryContainer: Colors.grey, background: const Color(0xFF212121))
        .copyWith(secondary: Colors.white),
  );

  static final lightTheme = ThemeData(
    primaryColor: Colors.white,
    brightness: Brightness.light,
    dividerColor: Colors.white54,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.blueGrey.shade500),
    appBarTheme: AppBarTheme(
      color: Colors.blueGrey.shade500,
    ),
    colorScheme: ColorScheme.light(primary: const Color(0xff303F9F))
        .copyWith(
            primaryContainer: Colors.grey, background: const Color(0xFFE5E5E5))
        .copyWith(secondary: Colors.black),
  );
}
