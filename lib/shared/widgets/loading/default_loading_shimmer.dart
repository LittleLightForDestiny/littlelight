import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:shimmer/shimmer.dart';

class DefaultLoadingShimmer extends StatelessWidget {
  final Widget? child;

  const DefaultLoadingShimmer({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LittleLightTheme.of(context).onSurfaceLayers.withOpacity(.2),
      highlightColor: LittleLightTheme.of(context).onSurfaceLayers,
      child: child ?? Container(color: LittleLightTheme.of(context).onSurfaceLayers),
    );
  }
}
