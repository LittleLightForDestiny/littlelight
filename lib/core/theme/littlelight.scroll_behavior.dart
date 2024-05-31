import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class LittleLightScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    if (Platform.isIOS || Platform.isMacOS) {
      return child;
    }
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: context.theme.primaryLayers.layer0,
      child: child,
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
        PointerDeviceKind.trackpad,
      };
}
