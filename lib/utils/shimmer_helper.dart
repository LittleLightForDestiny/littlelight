import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHelper {
  static getDefaultShimmer(BuildContext context, {Widget? child}) {
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: LittleLightTheme.of(context).onSurfaceLayers.withOpacity(.2),
        highlightColor: LittleLightTheme.of(context).onSurfaceLayers,
        child: child ?? Container(color: LittleLightTheme.of(context).onSurfaceLayers));
    return shimmer;
  }
}
