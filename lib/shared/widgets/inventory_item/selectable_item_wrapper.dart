import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/widgets/shapes/diamond_shape.dart';
import 'package:little_light/shared/widgets/shapes/engram_shape.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

import 'inventory_item.dart';

class SelectableItemWrapper extends StatelessWidget {
  final InventoryItemWidgetDensity? density;
  final DestinyItemInfo item;
  final Widget child;
  final double borderWidth;

  SelectableItemWrapper(this.child, {required this.item, this.density, this.borderWidth = 2});
  @override
  Widget build(BuildContext context) {
    if (density != null) return buildWithDensity(context, density!);
    final hash = this.item.item.itemHash;
    final itemInstanceId = this.item.item.itemInstanceId;
    return LayoutBuilder(
        key: Key("selectable $hash $itemInstanceId"),
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
    final hash = item.item.itemHash;
    if (hash == null) return Container();
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
        hash,
        (def) => Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(borderWidth),
                    child: child,
                  ),
                ),
                Positioned.fill(
                  child: buildButton(context, density, def),
                )
              ],
            ));
  }

  Widget buildButton(
      BuildContext context, InventoryItemWidgetDensity density, DestinyInventoryItemDefinition definition) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: buildInkwellShape(context, density, definition),
        onTap: () {},
      ),
    );
  }

  ShapeBorder? buildInkwellShape(
      BuildContext context, InventoryItemWidgetDensity density, DestinyInventoryItemDefinition definition) {
    if (density != InventoryItemWidgetDensity.Low) return null;
    if (definition.isEngram) return EngramBorder();
    if (definition.isSubclass) return DiamondBorder();
    return null;
  }
}
