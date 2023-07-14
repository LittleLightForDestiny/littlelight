import 'package:flutter/material.dart';

enum ScreenSize { ExtraSmall, Small, Medium, Large }

extension MediaQueryContextExtension on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
}

extension MediaQueryHelpers on MediaQueryData {
  bool get tabletOrBigger => biggerThan(ScreenSize.Small);
  bool get laptopOrBigger => biggerThan(ScreenSize.Medium);
  bool get isDesktop => biggerThan(ScreenSize.Large);
  bool get isPortrait => this.size.width < this.size.height;
  bool get isLandscape => this.size.width >= this.size.height;

  bool biggerThan([ScreenSize size = ScreenSize.ExtraSmall]) {
    switch (size) {
      case ScreenSize.ExtraSmall:
        return true;
      case ScreenSize.Small:
        return this.size.width >= 768;
      case ScreenSize.Medium:
        return this.size.width >= 992;
      case ScreenSize.Large:
        return this.size.width >= 1200;
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
        return this.size.width < 768;
      case ScreenSize.Small:
        return this.size.width < 992;
      case ScreenSize.Medium:
        return this.size.width < 1200;
      case ScreenSize.Large:
        return true;
    }
  }
}

class MediaQueryHelper {
  BuildContext context;

  MediaQueryHelper(this.context);

  bool get tabletOrBigger => biggerThan(ScreenSize.Small);
  bool get laptopOrBigger => biggerThan(ScreenSize.Medium);
  bool get isDesktop => biggerThan(ScreenSize.Large);
  bool get isPortrait => context.mediaQuery.isPortrait;
  bool get isLandscape => context.mediaQuery.isLandscape;

  bool biggerThan([ScreenSize size = ScreenSize.ExtraSmall]) => context.mediaQuery.biggerThan(size);

  T responsiveValue<T>(T phone, {T? tablet, T? laptop, T? desktop}) => context.mediaQuery.responsiveValue(
        phone,
        tablet: tablet,
        laptop: laptop,
        desktop: desktop,
      );

  bool smallerThan([ScreenSize size = ScreenSize.ExtraSmall]) => context.mediaQuery.smallerThan(size);
}
