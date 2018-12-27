import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHelper {
  static getDefaultShimmer(BuildContext context, {Widget child}) {
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .1),
        highlightColor: Colors.grey.shade300,
        child: child ?? Container(color: Colors.white));
    return shimmer;
  }
}
