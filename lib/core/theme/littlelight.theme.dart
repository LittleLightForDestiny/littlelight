//@dart=2.12

import 'package:flutter/material.dart';

class LittleLightTheme {
  Color _baseTextColor = Colors.grey.shade100;

  InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
        color: colorScheme.secondaryVariant,
        width: 1,
      )));

  ColorScheme get colorScheme => ColorScheme.dark(
      brightness: Brightness.dark,
      background: Color.fromARGB(255, 1, 9, 38),
      primary: Color.fromARGB(255, 0, 119, 182),
      primaryVariant: Color.fromARGB(255, 22, 59, 94),
      secondary: Color.fromARGB(255, 63, 152, 200),
      secondaryVariant: Color.fromARGB(255, 170, 200, 227),
      surface: Color.fromARGB(255, 55, 81, 134),
      onSurface: Color.fromARGB(255, 22, 59, 94),
      error: Color.fromARGB(255, 184, 2, 59),
      onPrimary: _baseTextColor);

  SnackBarThemeData get snackBarTheme =>
      SnackBarThemeData(contentTextStyle: TextStyle(color: Colors.blueGrey.shade100));

  ToggleButtonsThemeData get toggleButtonsTheme =>
      ToggleButtonsThemeData(color: Colors.blueGrey.shade500, selectedColor: Colors.lightBlue.shade600);

  MaterialColor _getSwitchColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Colors.lightBlue;
    }
    return Colors.blueGrey;
  }

  AppBarTheme get _appBarTheme => AppBarTheme(backgroundColor: colorScheme.surface);

  SwitchThemeData get switchTheme => SwitchThemeData(
        splashRadius: 14,
        overlayColor: MaterialStateColor.resolveWith((states) => _getSwitchColor(states).withOpacity(.4)),
        trackColor: MaterialStateColor.resolveWith((states) => _getSwitchColor(states).shade700),
        thumbColor: MaterialStateColor.resolveWith((states) => _getSwitchColor(states).shade400),
      );

  TextTheme get _textTheme => TextTheme(
      headline1: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      bodyText1: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      button: TextStyle(fontSize: 15, fontWeight: FontWeight.w600));

  CardTheme get _cardTheme => CardTheme(color: colorScheme.background);

  ThemeData get theme => ThemeData.from(colorScheme: colorScheme).copyWith(
      cardColor: colorScheme.background,
      cardTheme: _cardTheme,
      snackBarTheme: snackBarTheme,
      toggleButtonsTheme: toggleButtonsTheme,
      primaryColor: Colors.lightBlue.shade700,
      appBarTheme: _appBarTheme,
      inputDecorationTheme: _inputDecorationTheme,
      toggleableActiveColor: colorScheme.primary,
      textTheme: _textTheme,
      switchTheme: switchTheme);
}
