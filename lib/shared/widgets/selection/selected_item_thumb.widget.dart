import 'package:flutter/material.dart';
import 'package:bungie_api/src/models/destiny_inventory_item_definition.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';

class SelectedItemThumb extends LowDensityInventoryItem {
  const SelectedItemThumb(DestinyItemInfo item) : super(item);

  @override
  Widget buildQuantity(BuildContext context, DestinyInventoryItemDefinition definition) {
    int? quantity = item.item.quantity;
    if (quantity == null) return Container();
    TextStyle? textStyle = context.textTheme.itemPrimaryStatLowDensity;
    quantity = item.duplicates?.fold<int>(0, (v, item) => v + (item.item.quantity ?? 0)) ?? quantity;
    return buildInfoContainer(context, [
      Text(
        "x$quantity",
        style: textStyle,
        softWrap: false,
        textAlign: TextAlign.right,
      )
    ]);
  }
}
