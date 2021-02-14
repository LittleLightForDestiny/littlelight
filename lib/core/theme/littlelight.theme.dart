import 'package:flutter/material.dart';

class LittleLightTheme {
  Color _baseTextColor = Colors.grey.shade100;

  ColorScheme get colorScheme => ColorScheme.dark(
      brightness: Brightness.dark,
      background: Colors.blueGrey.shade900,
      primary: Colors.lightBlue.shade700,
      primaryVariant: Colors.blueGrey,
      surface: Colors.blueGrey.shade700,
      onSurface: Colors.blueGrey.shade600,
      error: Colors.red.shade700,
      onPrimary: _baseTextColor);

  SnackBarThemeData get snackBarTheme => SnackBarThemeData(
      contentTextStyle: TextStyle(color: Colors.blueGrey.shade100));

  ToggleButtonsThemeData get toggleButtonsTheme => ToggleButtonsThemeData(
      color: Colors.blueGrey.shade500,
      selectedColor: Colors.lightBlue.shade600);

  MaterialColor _getSwitchColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Colors.lightBlue;
    }
    return Colors.blueGrey;
  }

  SwitchThemeData get switchTheme => SwitchThemeData(
        splashRadius: 14,
        overlayColor: MaterialStateColor.resolveWith(
            (states) => _getSwitchColor(states).withOpacity(.4)),
        trackColor: MaterialStateColor.resolveWith(
            (states) => _getSwitchColor(states).shade700),
        thumbColor: MaterialStateColor.resolveWith(
            (states) => _getSwitchColor(states).shade400),
      );

  ThemeData get theme => ThemeData.from(colorScheme: colorScheme).copyWith(
      snackBarTheme: snackBarTheme,
      toggleButtonsTheme: toggleButtonsTheme,
      // toggleableActiveColor: colorScheme.primary,
      switchTheme: switchTheme);
}
