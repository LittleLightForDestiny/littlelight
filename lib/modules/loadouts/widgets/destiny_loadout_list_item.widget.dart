import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

const _notFoundIconHash = 29505215;

class DestinyLoadoutListItemWidget extends StatelessWidget {
  final DestinyLoadoutInfo loadout;

  final VoidCallback? onTap;
  const DestinyLoadoutListItemWidget(
    this.loadout, {
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorDef = context.definition<DestinyLoadoutColorDefinition>(loadout.loadout.colorHash);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        child: Stack(
          children: [
            Positioned.fill(child: QueuedNetworkImage.fromBungie(colorDef?.colorImagePath, fit: BoxFit.cover)),
            Container(
              padding: EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildLoadoutTitle(context),
                  Container(height: 4),
                  buildItems(context),
                ],
              ),
            ),
            Positioned.fill(
                child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: onTap,
                child: Container(),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget buildLoadoutTitle(BuildContext context) {
    final iconDef = context.definition<DestinyLoadoutIconDefinition>(loadout.loadout.iconHash);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [
            context.theme.surfaceLayers.layer0.withOpacity(.7),
            context.theme.surfaceLayers.layer0.withOpacity(0)
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            child: QueuedNetworkImage.fromBungie(iconDef?.iconImagePath),
          ),
          Container(
            width: 4,
          ),
          ManifestText<DestinyLoadoutNameDefinition>(
            loadout.loadout.nameHash,
            textExtractor: (def) => def.name?.toUpperCase(),
            style: context.textTheme.itemNameHighDensity,
          ),
        ],
      ),
    );
  }

  Widget buildItems(BuildContext context) {
    final items = loadout.items;
    if (items == null) return Container();
    if (items.isEmpty) return Container();
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: buildItem(context, InventoryBucket.subclass)),
            Expanded(child: buildItem(context, InventoryBucket.kineticWeapons)),
            Expanded(child: buildItem(context, InventoryBucket.energyWeapons)),
            Expanded(child: buildItem(context, InventoryBucket.powerWeapons)),
            Expanded(child: buildItem(context, InventoryBucket.helmet)),
            Expanded(child: buildItem(context, InventoryBucket.gauntlets)),
            Expanded(child: buildItem(context, InventoryBucket.chestArmor)),
            Expanded(child: buildItem(context, InventoryBucket.legArmor)),
            Expanded(child: buildItem(context, InventoryBucket.classArmor)),
          ],
        )
      ],
    );
  }

  Widget buildItem(BuildContext context, int bucketHash) {
    final item = loadout.items?[bucketHash];
    if (item == null) return buildItemNotFound(context);
    return Container(
        padding: EdgeInsets.all(1),
        child: InventoryItemIcon(
          item,
          borderSize: 1,
        ));
  }

  Widget buildItemNotFound(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.theme.surfaceLayers.layer1,
            border: Border.all(color: context.theme.onSurfaceLayers.layer3, width: 2),
          ),
          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            _notFoundIconHash,
            color: context.theme.errorLayers.layer3,
          ),
        ));
  }
}
