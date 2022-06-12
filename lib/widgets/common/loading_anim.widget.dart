import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:shimmer/shimmer.dart';

class LoadingAnimWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: 96,
            child: Shimmer.fromColors(
              baseColor: LittleLightTheme.of(context).onSurfaceLayers.layer2,
              highlightColor: LittleLightTheme.of(context).surfaceLayers.layer2,
              child: Image.asset("assets/anim/loading.webp"),
            )));
  }
}
