import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import 'package:little_light/shared/utils/extensions/element_type_data.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/utils/extensions/wishlist_tag_data.dart';
import 'package:little_light/shared/widgets/inventory_item/short_item_expiration_date.widget.dart';
import 'package:little_light/shared/widgets/objectives/multi_objective_progress.widget.dart';
import 'package:little_light/shared/widgets/shapes/diamond_shape.dart';
import 'package:little_light/utils/stats_total.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';
import 'inventory_item_icon.dart';
import 'utils/get_energy_capacity.dart';
import 'utils/get_subclass_super_plug_item.dart';

const _tagIconSize = 12.0;
const _primaryStatIconsSize = 10.0;

class LowDensityInventoryItem extends StatelessWidget with WishlistsConsumer, ManifestConsumer {
  final DestinyItemInfo item;
  final bool showCharacterIcon;
  const LowDensityInventoryItem(
    this.item, {
    Key? key,
    this.showCharacterIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemHash = item.itemHash;
    if (itemHash == null) return emptyItem(context);
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
      itemHash,
      (def) => buildWithDefinition(context, def),
    );
  }

  Widget emptyItem(BuildContext context) => Container();

  Widget buildWithDefinition(BuildContext context, DestinyInventoryItemDefinition? definition) {
    return ClipRRect(
        child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: buildItemIcon(context, definition)),
        Positioned(left: 2, bottom: 2, right: 2, top: 2, child: buildItemInfo(context, definition)),
      ],
    ));
  }

  Widget buildItemIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition == null) return SizedBox();
    if (definition.isSubclass) return buildSubclassIcon(context, definition);
    return InventoryItemIcon(item, borderSize: 1.5);
  }

  Widget buildSubclassIcon(BuildContext context, DestinyInventoryItemDefinition definition) {
    final subclassColor = definition.talentGrid?.hudDamageType?.getColorLayer(context).layer0 ?? Colors.transparent;
    return Container(
      alignment: Alignment.centerLeft,
      child: AspectRatio(
        aspectRatio: 1,
        child: FutureBuilder<DestinyInventoryItemDefinition?>(
          future: getSubclassSuperPlugItem(manifest, item, definition),
          builder: (context, snapshot) {
            final imgUrl = snapshot.data?.displayProperties?.icon;
            if (imgUrl == null) return Container();
            return Stack(children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DiamondShapePainter.color(context.theme.onSurfaceLayers.layer1),
                ),
              ),
              Positioned.fill(
                child: Container(
                    padding: const EdgeInsets.all(2),
                    child: CustomPaint(
                      painter: DiamondShapePainter.color(subclassColor),
                    )),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                child: QueuedNetworkImage.fromBungie(imgUrl),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget buildItemInfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition?.isEngram ?? false) return buildEngramInfo(context, definition);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildHeaderInfo(context, definition),
        Expanded(child: Container()),
        buildWishlistIcons(context, definition),
        if (definition?.isArmor ?? false) buildTotalStats(context, definition),
        buildItemPrimaryinfo(context, definition),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildEngramInfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      alignment: Alignment.bottomCenter,
      child: buildEngramPrimaryStat(context, definition),
    );
  }

  Widget buildItemPrimaryinfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition == null) return Container();
    if (definition.isSubclass) {
      return Container();
    }
    if (definition.isWeapon) {
      return buildWeaponPrimaryStat(context, definition);
    }
    if (definition.isArmor) {
      return buildArmorPrimaryStat(context, definition);
    }
    if (definition.isGhost) {
      return buildGhostPrimaryStat(context, definition);
    }
    if (definition.isQuestStep) {
      return buildQuestStepProgress(context, definition);
    }
    final isStack = (definition.inventory?.maxStackSize ?? 0) > 1;
    if (isStack) {
      return buildQuantity(context, definition);
    }
    return buildDefaultPrimaryStat(context, definition);
  }

  Widget buildWeaponPrimaryStat(BuildContext context, DestinyInventoryItemDefinition definition) {
    final damageType = item.damageType;
    final damageColor = damageType?.getColorLayer(context).layer2;
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatLowDensity;
    final ammoType = definition.equippingBlock?.ammoType;
    return buildInfoContainer(context, [
      Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Transform.translate(
            offset: Offset(0, 1),
            child: Icon(
              ammoType?.icon,
              color: ammoType?.color,
              size: textStyle.fontSize,
            )),
      ),
      Flexible(
          child: Text(
        "$powerLevel",
        style: textStyle.copyWith(color: damageColor),
        overflow: TextOverflow.fade,
        softWrap: false,
      )),
    ]);
  }

  Widget buildArmorPrimaryStat(BuildContext context, DestinyInventoryItemDefinition definition) {
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatLowDensity;
    return buildInfoContainer(context, [
      Padding(
        padding: const EdgeInsets.only(right: 2),
        child: FutureBuilder<DestinyEnergyCapacityEntry?>(
            future: getEnergyCapacity(manifest, item, definition),
            builder: (context, snapshot) {
              final capacity = snapshot.data;
              if (capacity == null) return Container();
              final energyLevel = capacity.capacityValue ?? 0;
              final textStyle = context.textTheme.itemPrimaryStatLowDensity;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "$energyLevel",
                      style: textStyle.copyWith(color: context.theme.onSurfaceLayers.layer1),
                    ),
                    Container(
                      margin: EdgeInsets.all(2).copyWith(right: 0),
                      color: context.theme.onSurfaceLayers,
                      width: .5,
                    ),
                  ],
                ),
              );
            }),
      ),
      Flexible(
          child: Text(
        "$powerLevel",
        style: textStyle,
        overflow: TextOverflow.fade,
        softWrap: false,
      )),
    ]);
  }

  Widget buildGhostPrimaryStat(BuildContext context, DestinyInventoryItemDefinition definition) {
    return buildInfoContainer(context, [
      FutureBuilder<DestinyEnergyCapacityEntry?>(
          future: getEnergyCapacity(manifest, item, definition),
          builder: (context, snapshot) {
            final capacity = snapshot.data;
            if (capacity == null) return Container();
            final energyLevel = capacity.capacityValue ?? 0;
            final textStyle = context.textTheme.itemPrimaryStatLowDensity;
            return Text(
              "$energyLevel",
              style: textStyle,
            );
          }),
    ]);
  }

  Widget buildQuestStepProgress(BuildContext context, DestinyInventoryItemDefinition definition) {
    final objectiveHashes = definition.objectives?.objectiveHashes;
    if (objectiveHashes == null) return Container();
    return buildInfoContainer(context, [
      Expanded(
        child: MultiObjectiveProgressWidget(
          objectiveHashes,
          objectives: item.objectives?.objectives,
        ),
      )
    ]);
  }

  Widget buildInfoContainer(BuildContext context, List<Widget> rowChildren) {
    if (rowChildren.isEmpty) return Container();
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer0,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: rowChildren,
      ),
    );
  }

  Widget buildHeaderInfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition?.isQuestStep ?? false) {
      return buildExpiryDate(context, definition);
    }
    return buildInfoContainer(
      context,
      [
        buildHeaderTagIcons(context, definition),
        buildLockedIcon(context, definition),
      ].whereType<Widget>().toList(),
    );
  }

  Widget? buildLockedIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final isLocked = item.state?.contains(ItemState.Locked) ?? false;
    if (!isLocked) return null;
    return SizedBox(
      height: _tagIconSize,
      width: _tagIconSize,
      child: Icon(
        FontAwesomeIcons.lock,
        size: _tagIconSize - 2,
        color: definition?.inventory?.tierType?.getTextColor(context),
      ),
    );
  }

  Widget? buildWishlistIcons(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final itemHash = item.itemHash;
    final reusablePlugs = item.reusablePlugs;
    if (itemHash == null || reusablePlugs == null) return null;
    final tags = wishlistsService.getWishlistBuildTags(itemHash: itemHash, reusablePlugs: reusablePlugs);
    if (tags.isEmpty) return null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tags
          .map((tag) {
            final color = tag.getColor(context);
            final borderColor = tag.getBorderColor(context);
            final icon = tag.getIcon(context);
            return Container(
              margin: const EdgeInsets.only(left: 2, bottom: 2),
              width: _tagIconSize,
              height: _tagIconSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1, color: borderColor),
              ),
              child: Icon(icon, size: _tagIconSize - 2),
            );
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  Widget? buildHeaderTagIcons(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final itemHash = item.itemHash;
    final itemInstanceId = item.instanceId;
    if (itemHash == null) return null;
    final itemNotes = context.watch<ItemNotesBloc>();
    final tags = itemNotes.tagsFor(itemHash, itemInstanceId);
    if (tags == null || tags.isEmpty) return null;
    return Row(
      children: tags
          .map((tag) {
            final color = tag.backgroundColor;
            final foregroundColor = tag.foregroundColor;
            final borderColor = tag.foregroundColor;
            final icon = tag.iconData;
            return Container(
              width: _tagIconSize,
              height: _tagIconSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(width: 1.0, color: borderColor ?? color ?? Colors.transparent),
              ),
              child: Icon(icon, size: _tagIconSize - 2, color: foregroundColor),
            );
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  Widget buildWeaponMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final damageType = item.damageType;
    final damageColor = damageType?.getColorLayer(context).layer2;
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatMediumDensity;
    final ammoType = definition.equippingBlock?.ammoType;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            ammoType?.icon,
            color: ammoType?.color,
            size: _primaryStatIconsSize,
          ),
        ),
        Flexible(
            child: Text(
          "$powerLevel",
          style: textStyle.copyWith(color: damageColor),
          overflow: TextOverflow.fade,
          softWrap: false,
        )),
      ],
    );
  }

  Widget buildDefaultPrimaryStat(BuildContext context, DestinyInventoryItemDefinition definition) {
    final primaryStatValue = item.primaryStatValue;
    if (primaryStatValue == null) return Container();
    final textStyle = context.textTheme.itemPrimaryStatLowDensity;
    return buildInfoContainer(context, [
      Text(
        "$primaryStatValue",
        style: textStyle,
        softWrap: false,
        textAlign: TextAlign.right,
      )
    ]);
  }

  Widget buildQuantity(BuildContext context, DestinyInventoryItemDefinition definition) {
    final quantity = item.quantity;
    final maxCount = definition.inventory?.maxStackSize;
    if (maxCount == null || maxCount == 1) return Container();
    TextStyle? textStyle = context.textTheme.itemPrimaryStatLowDensity;
    final isMaxValue = quantity == maxCount;
    if (isMaxValue) {
      textStyle = textStyle.copyWith(color: context.theme.highlightedObjectiveLayers.layer3);
    }
    return buildInfoContainer(context, [
      Text(
        "x$quantity",
        style: textStyle,
        softWrap: false,
        textAlign: TextAlign.right,
      )
    ]);
  }

  Widget buildExpiryDate(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final expiryDate = item.expirationDate;
    if (expiryDate == null) return Container();
    final isValid = DateTime.tryParse(expiryDate) != null;
    if (!isValid) return Container();
    final isObjectiveComplete = item.objectives?.objectives?.every((o) => o.complete ?? false) ?? false;
    if (isObjectiveComplete) return Container();
    return ShortExpiryDateWidget(
      expiryDate,
      style: context.textTheme.caption.copyWith(fontSize: 10),
    );
  }

  Widget buildEngramPrimaryStat(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final item = this.item;

    final itemLevel = item.itemLevel;
    final quality = item.quality ?? 0;
    if (itemLevel == null) return Container();
    if (itemLevel == 0) return Container();
    final level = itemLevel * 10 + quality;
    final textStyle = context.textTheme.itemPrimaryStatLowDensity;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: context.theme.surfaceLayers.layer0,
        ),
        child: Text(
          "$level",
          style: textStyle,
        ));
  }

  Widget? buildTotalStats(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final total = item.stats?.values.fold<int>(0, (t, stat) => t + (stat.value ?? 0));
    if (total == null) return null;
    final color = getStatsTotalColor(total, context);
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer0,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "T{statsTotal}".translate(context, replace: {"statsTotal": "$total"}),
        style: context.textTheme.subtitle.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }
}
