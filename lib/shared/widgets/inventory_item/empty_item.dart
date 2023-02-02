import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/shapes/diamond_shape.dart';

class EmptyItem extends StatelessWidget {
  final double borderWidth;
  final int? bucketHash;
  final InventoryItemWidgetDensity density;
  const EmptyItem({Key? key, this.borderWidth = 2, this.bucketHash, required this.density}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (density == InventoryItemWidgetDensity.Low) {
      return buildLowDensityBackground(context);
    }
    return buildDefaultBackground(context);
  }

  Widget buildLowDensityBackground(BuildContext context) {
    if (bucketHash == InventoryBucket.subclass) {
      return buildLowDensitySubclass(context);
    }
    if (bucketHash == InventoryBucket.engrams) {
      return buildLowDensityEngram(context);
    }
    return buildDefaultBackground(context);
  }

  Widget buildLowDensitySubclass(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderWidth),
      child: Stack(children: [
        Positioned.fill(
          child: CustomPaint(
            painter: DiamondShapePainter.color(
              context.theme.onSurfaceLayers.layer3 ?? Colors.transparent,
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(borderWidth),
            child: CustomPaint(
              painter: DiamondShapePainter.color(
                context.theme.surfaceLayers.layer1 ?? Colors.transparent,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildLowDensityEngram(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(borderWidth),
      child: Image.asset("assets/imgs/engram-placeholder.png"),
    );
  }

  Widget buildDefaultBackground(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        border: Border.all(
          width: borderWidth,
          color: context.theme.onSurfaceLayers.layer3 ?? Colors.transparent,
        ),
      ),
    );
  }
}
