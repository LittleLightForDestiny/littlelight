import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum SwatchLayer { Layer0, Layer1, Layer2, Layer3 }

extension ContextLittleLightTheme on BuildContext {
  LittleLightThemeData get theme => LittleLightTheme.of(this);
  LittleLightTextTheme get textTheme => theme.textTheme;
}

class LayeredSwatch extends Color {
  final Map<SwatchLayer, Color> _swatches;
  LayeredSwatch(this._swatches, {SwatchLayer defaultLayer = SwatchLayer.Layer0})
      : super(_swatches[defaultLayer]!.value);

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

  MaterialColor get asMaterialColor => MaterialColor(layer0.value, {
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

class DamageTypeLayers {
  LayeredSwatch damageTypeArc = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 36, 121, 177),
    SwatchLayer.Layer1: const Color(0xFFB8F3FF),
    SwatchLayer.Layer2: const Color(0xFFB8F3FF),
  });
  LayeredSwatch damageTypeThermal = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFFB43B0C),
    SwatchLayer.Layer1: const Color(0xFFF36227),
    SwatchLayer.Layer2: const Color(0xFFFF9C4A),
  });
  LayeredSwatch damageTypeVoid = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 77, 20, 148),
    SwatchLayer.Layer1: const Color(0xFFB178F8),
    SwatchLayer.Layer2: const Color(0xFFB178F8),
  });
  LayeredSwatch damageTypeStasis = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 40, 95, 204),
    SwatchLayer.Layer1: const Color(0xFF86A4FF),
    SwatchLayer.Layer2: const Color(0xFF86A4FF),
  });
  LayeredSwatch damageTypeStrand = LayeredSwatch({
    SwatchLayer.Layer0: Color(0xFF34E365),
    SwatchLayer.Layer1: Color(0xFF67EA8C),
    SwatchLayer.Layer2: Color(0xFF9AF1B2),
  });
  LayeredSwatch damageTypeKinetic = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFFABAFB0),
    SwatchLayer.Layer1: const Color(0xFFCACDCE),
    SwatchLayer.Layer2: const Color(0xFFDEE1E3),
  });
}

class ItemTierLayers {
  LayeredSwatch basic = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 195, 188, 180),
  });
  LayeredSwatch common = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 48, 107, 61),
  });
  LayeredSwatch rare = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 80, 118, 163),
  });
  LayeredSwatch superior = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 82, 47, 101),
  });
  LayeredSwatch exotic = LayeredSwatch({
    SwatchLayer.Layer0: const Color.fromARGB(255, 206, 174, 51),
  });
}

class LittleLightTextTheme {
  final TextStyle title;
  final TextStyle largeTitle;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle highlight;
  final TextStyle button;
  final TextStyle notification;
  final TextStyle itemNameHighDensity;
  final TextStyle itemPrimaryStatHighDensity;
  final TextStyle itemPrimaryStatMediumDensity;
  final TextStyle itemPrimaryStatLowDensity;
  final TextStyle caption;
  final TextStyle itemNameMediumDensity;
  final TextStyle primaryStatName;

  LittleLightTextTheme({
    required this.title,
    required this.largeTitle,
    required this.subtitle,
    required this.body,
    required this.highlight,
    required this.button,
    required this.notification,
    required this.itemNameHighDensity,
    required this.caption,
    required this.itemPrimaryStatHighDensity,
    required this.itemPrimaryStatMediumDensity,
    required this.itemPrimaryStatLowDensity,
    required this.itemNameMediumDensity,
    required this.primaryStatName,
  });
}

class LittleLightThemeData {
  DamageTypeLayers get damageTypeLayers => DamageTypeLayers();
  final tierLayers = ItemTierLayers();
  LittleLightTextTheme get textTheme => LittleLightTextTheme(
        largeTitle: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: onSurfaceLayers.layer0),
        title: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: onSurfaceLayers.layer0),
        subtitle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurfaceLayers.layer0),
        body: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: onSurfaceLayers.layer0),
        highlight: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: onSurfaceLayers.layer0),
        button: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurfaceLayers.layer0),
        notification: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurfaceLayers.layer0),
        itemNameHighDensity: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        itemNameMediumDensity: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        caption: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: onSurfaceLayers.layer0),
        primaryStatName: TextStyle(fontSize: 16, fontWeight: FontWeight.w200, color: onSurfaceLayers.layer0),
        itemPrimaryStatHighDensity: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: onSurfaceLayers.layer0),
        itemPrimaryStatMediumDensity:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: onSurfaceLayers.layer0),
        itemPrimaryStatLowDensity: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: onSurfaceLayers.layer0),
      );

  final surfaceLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFF181818),
    SwatchLayer.Layer1: const Color(0xFF2C2933),
    SwatchLayer.Layer2: const Color(0xFF44414A),
    SwatchLayer.Layer3: const Color(0xFF55525A),
  });

  final secondarySurfaceLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFF302537),
    SwatchLayer.Layer1: const Color(0xFF43344C),
    SwatchLayer.Layer2: const Color(0xFF4C3C56),
    SwatchLayer.Layer3: const Color(0xFF554360),
  });

  final onSurfaceLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFFF2F2F2),
    SwatchLayer.Layer1: const Color(0xFFDEE1E3),
    SwatchLayer.Layer2: const Color(0xFFCACDCE),
    SwatchLayer.Layer3: const Color(0xFFABAFB0),
  });

  final highlightedObjectiveLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFFD95738),
  });

  // final secondaryLayers = LayeredSwatch(
  //   SwatchLayer.Layer0: Color(0xFF)
  // );

  final primaryLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFF097EEC),
    SwatchLayer.Layer1: const Color(0xFF2F97F7),
    SwatchLayer.Layer2: const Color(0xFF7ABAF5),
  }, defaultLayer: SwatchLayer.Layer1);

  final achievementLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFFFFC107),
    SwatchLayer.Layer1: const Color(0xFFFFD965),
    SwatchLayer.Layer2: const Color(0xFFFFF0C2),
  });

  final upgradeLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFF00D6E6),
    SwatchLayer.Layer1: const Color(0xFF85E6EE),
    SwatchLayer.Layer2: const Color(0xFFCAF1F7),
  });

  final errorLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFFA30335),
    SwatchLayer.Layer1: const Color(0xFFB8023B),
    SwatchLayer.Layer2: const Color(0xFFC13C4E),
  }, defaultLayer: SwatchLayer.Layer1);

  final successLayers = LayeredSwatch({
    SwatchLayer.Layer0: const Color(0xFF45B319),
    SwatchLayer.Layer1: const Color(0xFF46E038),
  }, defaultLayer: SwatchLayer.Layer1);

  Color get _background => surfaceLayers.layer0;
  Color get _surface => surfaceLayers.layer1;
  Color get _secondaryContainer => secondarySurfaceLayers.layer0;
  Color get _secondary => secondarySurfaceLayers.layer1;

  Color get _primary => primaryLayers.layer0;
  Color get _primaryContainer => primaryLayers.layer0;

  ColorScheme get colorScheme => ColorScheme(
      brightness: Brightness.dark,
      background: _background,
      surface: _surface,
      primary: _primary,
      primaryContainer: _primaryContainer,
      secondary: _secondary,
      secondaryContainer: _secondaryContainer,
      onBackground: onSurfaceLayers.layer0,
      onPrimary: onSurfaceLayers.layer0,
      onSecondary: onSurfaceLayers.layer0,
      onSurface: onSurfaceLayers.layer0,
      onError: onSurfaceLayers.layer0,
      error: errorLayers.layer0);

  Color _getSwitchTrackColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return primaryLayers.layer0;
    }
    return onSurfaceLayers.layer0.withOpacity(.2);
  }

  Color _getSwitchThumbColor(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return primaryLayers.layer1;
    }
    return onSurfaceLayers.layer0.withOpacity(.4);
  }

  AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: secondarySurfaceLayers.layer0,
      );

  SwitchThemeData get _switchTheme => SwitchThemeData(
        splashRadius: 14,
        overlayColor: MaterialStateColor.resolveWith((states) => onSurfaceLayers.layer0.withOpacity(.1)),
        trackColor: MaterialStateColor.resolveWith((states) => _getSwitchTrackColor(states)),
        thumbColor: MaterialStateColor.resolveWith((states) => _getSwitchThumbColor(states)),
      );

  TextTheme get _textTheme => TextTheme(
        displayMedium: textTheme.title,
        bodyMedium: textTheme.body,
        labelLarge: textTheme.button,
      );

  CardTheme get _cardTheme => CardTheme(color: colorScheme.surface);

  MaterialStateTextStyle get labelStyle => MaterialStateTextStyle.resolveWith((states) {
        final focus = states.contains(MaterialState.focused) || states.contains(MaterialState.selected);
        if (focus) {
          return textTheme.caption.copyWith(color: primaryLayers.layer3, fontSize: 18);
        }
        return textTheme.caption.copyWith(fontSize: 16);
      });

  ThemeData get materialTheme => ThemeData.from(colorScheme: colorScheme).copyWith(
        primaryColor: primaryLayers,
        appBarTheme: _appBarTheme,
        cardColor: _cardTheme.color,
        cardTheme: _cardTheme,
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
          foregroundColor: MaterialStateColor.resolveWith((states) => primaryLayers.layer3),
        )),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLayers,
            disabledForegroundColor: primaryLayers,
            disabledBackgroundColor: primaryLayers,
          ),
        ),
        toggleButtonsTheme: ToggleButtonsThemeData(
          selectedColor: primaryLayers.layer1,
          color: surfaceLayers.layer2,
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 12,
          trackShape: RoundedRectSliderTrackShape(),
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
          activeTrackColor: primaryLayers.layer0,
          inactiveTrackColor: onSurfaceLayers.layer3,
          thumbColor: onSurfaceLayers.layer0,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
        ),
        textTheme: _textTheme,
        switchTheme: _switchTheme,
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle: labelStyle,
          labelStyle: labelStyle,
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryLayers.layer3, width: 2)),
        ),
      );
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
        builder: (context, child) => Theme(data: theme.materialTheme, child: child ?? Container()),
        child: child);
  }

  static LittleLightThemeData of(BuildContext context) => context.read<LittleLightThemeData>();
}
