import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:shimmer/shimmer.dart';

class DefaultLoadingShimmer extends StatelessWidget {
  final bool enabled;
  final Widget? child;

  const DefaultLoadingShimmer({Key? key, this.child, this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: this.enabled ? context.theme.onSurfaceLayers.withOpacity(.2) : context.theme.onSurfaceLayers,
      highlightColor: context.theme.onSurfaceLayers,
      enabled: this.enabled,
      child: child ?? Container(color: LittleLightTheme.of(context).onSurfaceLayers),
    );
  }
}
