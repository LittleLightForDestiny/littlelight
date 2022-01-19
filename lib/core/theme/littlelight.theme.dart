//@dart=2.12

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SwatchLayer { Layer0, Layer1, Layer2, Layer3 }

class LayeredSwatch extends Color {
  final Map<SwatchLayer, Color> _swatches;
  LayeredSwatch(this._swatches) : super(_swatches[SwatchLayer.Layer0]!.value);

  Color get layer0 => _swatches[SwatchLayer.Layer0] ?? this;
  Color get layer1 => _swatches[SwatchLayer.Layer1] ?? layer0;
  Color get layer2 => _swatches[SwatchLayer.Layer2] ?? layer1;
  Color get layer3 => _swatches[SwatchLayer.Layer3] ?? layer2;

  LayeredSwatch get reverse {
    final indexes = _swatches.keys.map((k) => SwatchLayer.values.indexOf(k)).toList();
    final reversedIndex = indexes.reversed.toList();
    final _reversedSwatches = _swatches.map((key, value) {
      final index = SwatchLayer.values.indexOf(key);
      final internalIndex = indexes.indexOf(index);
      final newIndex = reversedIndex[internalIndex];
      final newKey = SwatchLayer.values[newIndex];
      return MapEntry(newKey, value);
    });
    return LayeredSwatch(_reversedSwatches);
  }

  MaterialColor get asMaterialColor => MaterialColor(this.layer0.value, {
        100: layer0,
        200: layer0,
        300: layer0,
        400: layer0,
        500: layer1,
        600: layer1,
        700: layer1,
        800: layer2,
        900: layer3
      });
}

class LittleLightTextTheme {
  final TextStyle title = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  final TextStyle subtitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  final TextStyle body = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  final TextStyle button = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}

class LittleLightThemeData {
  final textTheme = LittleLightTextTheme();

  final surfaceLayers = LayeredSwatch({
    SwatchLayer.Layer0: Color(0xFF21212B),
    SwatchLayer.Layer1: Color(0xFF2B3A45),
    SwatchLayer.Layer2: Color(0xFF3E4C56),
    SwatchLayer.Layer3: Color(0xFF4D5E6A),
  });

  final onSurfaceLayers = LayeredSwatch({
    SwatchLayer.Layer0: Color(0xFFF2F2F2),
    SwatchLayer.Layer1: Color(0xFFDEE1E3),
    SwatchLayer.Layer2: Color(0xFFCACDCE),
  });

  final primaryLayers = LayeredSwatch({
    SwatchLayer.Layer0: Color(0xFF097EEC),
    SwatchLayer.Layer1: Color(0xFF2F97F7),
    SwatchLayer.Layer2: Color(0xFF7ABAF5),
  });

  final achievementLayers = LayeredSwatch({
    SwatchLayer.Layer0: Color(0xFFFFC107),
    SwatchLayer.Layer1: Color(0xFFFFD965),
    SwatchLayer.Layer2: Color(0xFFFFF0C2),
  });

  final upgradeLayers = LayeredSwatch({
    SwatchLayer.Layer0: Color(0xFF85E6EE),
    SwatchLayer.Layer1: Color(0xFFCAF1F7),
  });

  final errorLayers = LayeredSwatch({
    SwatchLayer.Layer0: Color(0xFFB8023B),
    SwatchLayer.Layer1: Color(0xFFA30335),
    SwatchLayer.Layer2: Color(0xFF8E042F),
    SwatchLayer.Layer3: Color(0xFF630523),
  });

  Color get _background => surfaceLayers.layer0;
  Color get _surface => surfaceLayers.layer1;
  Color get _secondaryVariant => surfaceLayers.layer2;
  Color get _secondary => surfaceLayers.layer3;

  Color get _primary => const Color.fromARGB(255, 63, 152, 200);
  Color get _primaryVariant => const Color.fromARGB(255, 0, 119, 182);
        

  // InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
  //         enabledBorder: UnderlineInputBorder(
  //             borderSide: BorderSide(
  //       color: colorScheme.secondaryVariant,
  //       width: 1,
  //     )));

  ColorScheme get colorScheme => ColorScheme(
      brightness: Brightness.dark,
      background: _background,
      surface: _surface,
      primary: _primary,
      primaryVariant: _primaryVariant,
      secondary: _secondary,
      secondaryVariant: _secondaryVariant,
      onBackground: onSurfaceLayers.layer0,
      onPrimary: onSurfaceLayers.layer0,
      onSecondary: onSurfaceLayers.layer0,
      onSurface: onSurfaceLayers.layer0,
      onError: onSurfaceLayers.layer0,
      error: errorLayers.layer0);

  // SnackBarThemeData get snackBarTheme =>
  //     SnackBarThemeData(contentTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary));

  // ToggleButtonsThemeData get toggleButtonsTheme =>
  //     ToggleButtonsThemeData(color: Theme.of(context).colorScheme.secondary, selectedColor: Colors.lightBlue.shade600);

  MaterialColor _getSwitchColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return primaryLayers.reverse.asMaterialColor;
    }
    return surfaceLayers.reverse.asMaterialColor;
  }

  AppBarTheme get _appBarTheme => AppBarTheme(backgroundColor: surfaceLayers.layer1);

  SwitchThemeData get _switchTheme => SwitchThemeData(
        splashRadius: 14,
        overlayColor: MaterialStateColor.resolveWith((states) => _getSwitchColor(states).withOpacity(.4)),
        trackColor: MaterialStateColor.resolveWith((states) => _getSwitchColor(states).shade700),
        thumbColor: MaterialStateColor.resolveWith((states) => _getSwitchColor(states).shade400),
      );

  TextTheme get _textTheme => TextTheme(
      headline1: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      bodyText1: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      button: TextStyle(fontSize: 15, fontWeight: FontWeight.w600));

  CardTheme get _cardTheme => CardTheme(color: colorScheme.surface);

  ThemeData get materialTheme => ThemeData.from(colorScheme: colorScheme).copyWith(
      primaryColor: primaryLayers,
      appBarTheme: _appBarTheme,
      cardColor: _cardTheme.color,
      cardTheme: _cardTheme,
      // cardColor: colorScheme.background,
      // cardTheme: _cardTheme,
      // snackBarTheme: snackBarTheme,
      // toggleButtonsTheme: toggleButtonsTheme,
      // primaryColor: Colors.lightBlue.shade700,
      // appBarTheme: _appBarTheme,
      // inputDecorationTheme: _inputDecorationTheme,
      // toggleableActiveColor: colorScheme.primary,
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) => primaryLayers.layer3))),
      textTheme: _textTheme,
      switchTheme: _switchTheme);
}

class LittleLightTheme extends StatelessWidget {
  final Widget child;
  final LittleLightThemeData theme = LittleLightThemeData();

  LittleLightTheme(
    this.child, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<LittleLightThemeData>(
      create: (context) => theme,
      child: Theme(data: theme.materialTheme, child: child),
    );
  }

  static LittleLightThemeData of(BuildContext context) => context.read<LittleLightThemeData>();
}
