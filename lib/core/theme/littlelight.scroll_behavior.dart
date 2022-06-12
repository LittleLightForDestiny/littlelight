import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LittleLightScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isIOS || Platform.isMacOS) {
      return child;
    }
    return GlowingOverscrollIndicator(
      child: child,
      axisDirection: axisDirection,
      color: Theme.of(context).primaryColor,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Platform.isIOS) {
      return const BouncingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.unknown,
      };
}
