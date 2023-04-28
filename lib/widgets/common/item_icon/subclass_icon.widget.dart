import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class SubclassIconWidget extends ItemIconWidget {
  SubclassIconWidget(
    DestinyItemInfo? item,
    DestinyInventoryItemDefinition? definition,
    DestinyItemInstanceComponent? instanceInfo, {
    Key? key,
  }) : super(item, definition, instanceInfo, key: key);

  BoxDecoration? iconBoxDecoration() {
    return null;
  }

  @override
  Widget itemIconImage(BuildContext context) {
    return ManifestImageWidget<DestinyInventoryItemDefinition>(
      definition!.hash!,
      fit: BoxFit.fill,
      placeholder: itemIconPlaceholder(context),
    );
  }

  @override
  Widget itemIconPlaceholder(BuildContext context) {
    return DefaultLoadingShimmer(
        child: Icon(
      (definition?.classType ?? DestinyClass.Unknown).icon,
      size: 60,
    ));
  }
}
