import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/medium_density_inventory_item.dart';

enum InventoryItemWidgetDensity { Low, Medium, High }

extension IdealItemWidth on InventoryItemWidgetDensity {
  double get idealWidth {
    switch (this) {
      case InventoryItemWidgetDensity.Low:
        return 68;
      case InventoryItemWidgetDensity.Medium:
        return 116;
      case InventoryItemWidgetDensity.High:
        return 288;
    }
  }

  double? get itemHeight {
    switch (this) {
      case InventoryItemWidgetDensity.Low:
        return null;
      case InventoryItemWidgetDensity.Medium:
        return 72;
      case InventoryItemWidgetDensity.High:
        return 96;
    }
  }

  double? get itemAspectRatio {
    switch (this) {
      case InventoryItemWidgetDensity.Low:
        return 1;
      case InventoryItemWidgetDensity.Medium:
      case InventoryItemWidgetDensity.High:
        return null;
    }
  }

  int getIdealCount(double containerWidth) {
    return (containerWidth / idealWidth).floor().clamp(1, 100);
  }
}

class InventoryItemWidget extends StatelessWidget {
  final InventoryItemWidgetDensity? density;
  final DestinyItemInfo item;

  InventoryItemWidget(this.item, {this.density});

  @override
  Widget build(BuildContext context) {
    if (density != null) return buildWithDensity(context, density!);
    final hash = this.item.item.itemHash;
    final itemInstanceId = this.item.item.itemInstanceId;
    return LayoutBuilder(
        key: Key("$hash $itemInstanceId"),
        builder: (context, constraints) {
          if (constraints.maxWidth > InventoryItemWidgetDensity.High.idealWidth) {
            return buildWithDensity(context, InventoryItemWidgetDensity.High);
          }
          if (constraints.maxWidth > InventoryItemWidgetDensity.Medium.idealWidth) {
            return buildWithDensity(context, InventoryItemWidgetDensity.Medium);
          }
          return buildWithDensity(context, InventoryItemWidgetDensity.Low);
        });
  }

  Widget buildWithDensity(BuildContext context, InventoryItemWidgetDensity density) {
    switch (density) {
      case InventoryItemWidgetDensity.Low:
        return LowDensityInventoryItem(item);
      case InventoryItemWidgetDensity.Medium:
        return MediumDensityInventoryItem(item);
      case InventoryItemWidgetDensity.High:
        return HighDensityInventoryItem(item);
    }
  }
}
