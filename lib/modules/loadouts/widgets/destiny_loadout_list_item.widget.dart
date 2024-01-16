import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item_icon.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

const _notFoundIconHash = 29505215;

class DestinyLoadoutListItemWidget extends StatelessWidget {
  final DestinyLoadoutInfo loadout;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const DestinyLoadoutListItemWidget(
    this.loadout, {
    super.key,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.onSurfaceLayers.layer3, width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          child: Stack(
            children: [
              Positioned.fill(child: buildBackground(context)),
              Container(
                padding: EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildLoadoutTitle(context),
                    Container(
                      padding: EdgeInsets.all(4),
                      child: buildItems(context),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Container(),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    final colorDef = context.definition<DestinyLoadoutColorDefinition>(loadout.loadout.colorHash);
    if (colorDef == null) {
      return Container(
        color: context.theme.surfaceLayers.layer2,
      );
    }
    return QueuedNetworkImage.fromBungie(colorDef.colorImagePath, fit: BoxFit.cover);
  }

  Widget buildLoadoutTitle(BuildContext context) {
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
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(child: buildLoadoutName(context)),
          buildLoadoutIcon(context),
        ],
      ),
    );
  }

  Widget buildLoadoutName(BuildContext context) {
    final name = context.definition<DestinyLoadoutNameDefinition>(loadout.loadout.nameHash)?.name;
    if (name == null) {
      return Text("New Loadout".translate(context).toUpperCase(), style: context.textTheme.itemNameHighDensity);
    }
    return Text(name.toUpperCase(), style: context.textTheme.itemNameHighDensity);
  }

  Widget buildLoadoutIcon(BuildContext context) {
    final iconDef = context.definition<DestinyLoadoutIconDefinition>(loadout.loadout.iconHash);
    if (iconDef == null) {
      return Container(
          width: 24,
          height: 24,
          child: Icon(
            FontAwesomeIcons.squarePlus,
            size: 18,
          ));
    }
    return Container(
      width: 24,
      height: 24,
      child: QueuedNetworkImage.fromBungie(iconDef.iconImagePath),
    );
  }

  Widget buildItems(BuildContext context) {
    final items = loadout.items;
    if (items == null || items.isEmpty)
      return Container(
        padding: EdgeInsets.all(4),
        child: Text("Select this slot to save the currently equipped items as a new loadout"),
      );
    return Column(
      children: [
        Row(
          children: [
            Flexible(child: buildItem(context, InventoryBucket.subclass)),
            Flexible(child: buildItem(context, InventoryBucket.kineticWeapons)),
            Flexible(child: buildItem(context, InventoryBucket.energyWeapons)),
            Flexible(child: buildItem(context, InventoryBucket.powerWeapons)),
            Flexible(child: buildItem(context, InventoryBucket.helmet)),
            Flexible(child: buildItem(context, InventoryBucket.gauntlets)),
            Flexible(child: buildItem(context, InventoryBucket.chestArmor)),
            Flexible(child: buildItem(context, InventoryBucket.legArmor)),
            Flexible(child: buildItem(context, InventoryBucket.classArmor)),
          ],
        )
      ],
    );
  }

  Widget buildItem(BuildContext context, int bucketHash) {
    final item = loadout.items?[bucketHash];
    if (item == null) return buildItemNotFound(context);
    return Container(
        constraints: BoxConstraints(maxWidth: 32, maxHeight: 32),
        padding: EdgeInsets.all(1),
        child: AspectRatio(
            aspectRatio: 1,
            child: InventoryItemIcon(
              item,
              borderSize: 1,
            )));
  }

  Widget buildItemNotFound(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxWidth: 32, maxHeight: 32),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer1,
          border: Border.all(color: context.theme.onSurfaceLayers.layer3, width: 2),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
            _notFoundIconHash,
            color: context.theme.errorLayers.layer3,
          ),
        ));
  }
}
