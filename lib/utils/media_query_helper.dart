//@dart=2.12
import 'package:flutter/material.dart';

enum ScreenSize { ExtraSmall, Small, Medium, Large }

class MediaQueryHelper {
  BuildContext context;

  MediaQueryHelper(this.context);

  bool get tabletOrBigger => biggerThan(ScreenSize.Small);
  bool get laptopOrBigger => biggerThan(ScreenSize.Medium);
  bool get isDesktop => biggerThan(ScreenSize.Large);
  bool get isPortrait => MediaQuery.of(context).size.width <= MediaQuery.of(context).size.height;
  bool get isLandscape => MediaQuery.of(context).size.width >= MediaQuery.of(context).size.height;

  bool biggerThan([ScreenSize size = ScreenSize.ExtraSmall]) {
    switch (size) {
      case ScreenSize.ExtraSmall:
        return true;
      case ScreenSize.Small:
        return MediaQuery.of(context).size.width >= 768;
      case ScreenSize.Medium:
        return MediaQuery.of(context).size.width >= 992;
      case ScreenSize.Large:
        return MediaQuery.of(context).size.width >= 1200;
    }
  }

  T responsiveValue<T>(T phone, {T? tablet, T? laptop, T? desktop}) {
    if (biggerThan(ScreenSize.Large) && desktop != null) {
      return desktop;
    }
    if (biggerThan(ScreenSize.Medium) && laptop != null) {
      return laptop;
    }
    if (biggerThan(ScreenSize.Small) && tablet != null) {
      return tablet;
    }

    return phone;
  }

  bool smallerThan([ScreenSize size = ScreenSize.ExtraSmall]) {
    switch (size) {
      case ScreenSize.ExtraSmall:
        return MediaQuery.of(context).size.width < 768;
      case ScreenSize.Small:
        return MediaQuery.of(context).size.width < 992;
      case ScreenSize.Medium:
        return MediaQuery.of(context).size.width < 1200;
      case ScreenSize.Large:
        return true;
    }
  }
}
