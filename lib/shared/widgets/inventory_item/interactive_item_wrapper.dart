import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/blocs/item_interaction_handler/item_interaction_handler.bloc.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/widgets/shapes/diamond_shape.dart';
import 'package:little_light/shared/widgets/shapes/engram_shape.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:provider/provider.dart';

import 'inventory_item.dart';

class InteractiveItemWrapper extends StatelessWidget {
  final InventoryItemWidgetDensity? density;
  final DestinyItemInfo item;
  final Widget child;
  final double itemMargin;
  final double selectedBorder;

  const InteractiveItemWrapper(this.child,
      {required this.item, this.density, this.itemMargin = 2, this.selectedBorder = 1});
  @override
  Widget build(BuildContext context) {
    if (density != null) return buildWithDensity(context, density!);
    final hash = item.item.itemHash;
    final itemInstanceId = item.item.itemInstanceId;
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
                    padding: EdgeInsets.all(itemMargin),
                    child: child,
                  ),
                ),
                Positioned.fill(child: buildSelectedBorder(context)),
                Positioned.fill(
                  child: buildButton(context, density, def),
                )
              ],
            ));
  }

  Widget buildSelectedBorder(BuildContext context) {
    final hash = item.item.itemHash;
    if (hash == null) return Container();
    final isSelected = context
        .watch<SelectionBloc>()
        .isSelected(hash, instanceId: item.item.itemInstanceId, stackIndex: item.stackIndex);
    if (!isSelected) return Container();
    return Container(
      margin: EdgeInsets.all(itemMargin - selectedBorder),
      decoration: BoxDecoration(
        border: Border.all(width: selectedBorder, color: LittleLightTheme.of(context).primaryLayers.layer1),
        color: LittleLightTheme.of(context).primaryLayers.layer1.withOpacity(.2),
      ),
    );
  }

  Widget buildButton(
    BuildContext context,
    InventoryItemWidgetDensity density,
    DestinyInventoryItemDefinition definition,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: buildInkwellShape(context, density, definition),
        onLongPress: () => onLongPress(context),
        onTap: () => onTap(context),
      ),
    );
  }

  ShapeBorder? buildInkwellShape(
    BuildContext context,
    InventoryItemWidgetDensity density,
    DestinyInventoryItemDefinition definition,
  ) {
    if (density != InventoryItemWidgetDensity.Low) return null;
    if (definition.isEngram) return EngramBorder();
    if (definition.isSubclass) return DiamondBorder();
    return null;
  }

  void onLongPress(BuildContext context) {
    final interaction = context.read<ItemInteractionHandlerBloc>();
    interaction.onHold(item);
  }

  void onTap(BuildContext context) {
    final interaction = context.read<ItemInteractionHandlerBloc>();
    interaction.onTap(item);
  }
}
