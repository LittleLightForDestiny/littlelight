import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

Color? getStatsTotalColor(int total, BuildContext context) {
  if (total >= 65) {
    return context.theme?.achievementLayers.layer2;
  }
  if (total >= 60) {
    return context.theme?.onSurfaceLayers.layer0;
  }
  return context.theme?.onSurfaceLayers.layer3;
}
