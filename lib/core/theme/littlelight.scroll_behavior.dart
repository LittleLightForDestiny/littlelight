//@dart=2.12
import 'dart:io';

import 'package:flutter/material.dart';

class LittleLightScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    if (Platform.isIOS || Platform.isMacOS) {
      return child;
    }
    return GlowingOverscrollIndicator(
      child: child,
      axisDirection: axisDirection,
      color: Theme.of(context).accentColor,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (Platform.isIOS) {
      return const BouncingScrollPhysics();
    }
    return super.getScrollPhysics(context);
  }
}
