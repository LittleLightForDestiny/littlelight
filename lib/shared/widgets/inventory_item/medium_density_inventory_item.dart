import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/craftables_helper.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/parsed_wishlist.dart';
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
import 'package:little_light/utils/color_utils.dart';
import 'package:little_light/utils/stats_total.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';

import 'inventory_item_icon.dart';
import 'inventory_item_mods.dart';
import 'utils/get_energy_capacity.dart';
import 'utils/get_mods_socket_category.dart';
import 'utils/get_subclass_super_plug_item.dart';

const _titleBarHeight = 24.0;
const _titleBarIconSize = 16.0;
const _iconWidth = 48.0;

class MediumDensityInventoryItem extends StatelessWidget with WishlistsConsumer, ManifestConsumer {
  final DestinyItemInfo item;
  final bool showCharacterIcon;
  const MediumDensityInventoryItem(
    this.item, {
    Key? key,
    this.showCharacterIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemHash = item.itemHash;
    if (itemHash == null) return emptyItem(context);
    final definition = context.definition<DestinyInventoryItemDefinition>(itemHash);
    return buildWithDefinition(context, definition);
  }

  Widget emptyItem(BuildContext context) => Container();

  Widget buildWithDefinition(BuildContext context, DestinyInventoryItemDefinition? definition) {
    return ClipRRect(
        child: Stack(
      fit: StackFit.expand,
      children: [
        buildBackground(context, definition),
        buildForeground(context, definition),
        Positioned(
          top: _titleBarHeight,
          bottom: 0,
          right: 0,
          left: 0,
          child: buildMainContent(context, definition),
        ),
      ],
    ));
  }

  Widget buildBackground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition?.isSubclass ?? false) return buildSubclassBackground(context, definition);
    return Column(
      children: [
        buildTitleBarBackground(context, definition),
        Expanded(child: buildMainBackground(context, definition)),
      ],
    );
  }

  Widget buildSubclassBackground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final subclassColor = definition?.talentGrid?.hudDamageType?.getColorLayer(context).layer0 ?? Colors.transparent;
    final bgColor = TinyColor.fromColor(subclassColor).darken(25).desaturate(30).color;
    return Container(
        color: bgColor,
        alignment: Alignment.centerRight,
        child: Transform.translate(
          offset: Offset(20, 0),
          child: Container(
            constraints: const BoxConstraints(minHeight: double.infinity),
            foregroundDecoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [bgColor.withValues(alpha: 0), bgColor],
                stops: const [.5, 1],
                radius: 1.8,
                center: Alignment.bottomRight,
              ),
            ),
            child: QueuedNetworkImage.fromBungie(
              definition?.screenshot,
              alignment: Alignment.centerRight,
              fit: BoxFit.fitHeight,
            ),
          ),
        ));
  }

  Widget buildTitleBarBackground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final isMasterwork = item.state?.contains(ItemState.Masterwork) ?? false;
    if (!isMasterwork) {
      return Container(
        color: definition?.inventory?.tierType?.getColor(context),
        height: _titleBarHeight,
      );
    }
    final isExotic = definition?.inventory?.tierType == TierType.Exotic;
    final theme = context.theme;
    final assetPath = isExotic ? "assets/imgs/masterwork-top-exotic.png" : "assets/imgs/masterwork-top.png";
    final borderColor = isExotic ? theme.achievementLayers.layer2 : theme.achievementLayers.layer1;
    return Stack(children: [
      Container(
        color: definition?.inventory?.tierType?.getColor(context),
        height: _titleBarHeight,
        foregroundDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2,
              color: borderColor,
            ),
          ),
          image: DecorationImage(
            image: ExactAssetImage(assetPath),
            repeat: ImageRepeat.repeatX,
          ),
        ),
      ),
    ]);
  }

  Widget buildMainBackground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition?.isEmblem ?? false) return buildEmblemMainBackground(context, definition);
    final theme = context.theme;
    return Container(
      color: theme.surfaceLayers.layer1,
      child: buildWishlistTagBackground(context, definition),
    );
  }

  Widget buildEmblemMainBackground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final url = definition?.secondarySpecial;
    if (url == null) {
      final color = definition?.backgroundColor?.toMaterialColor();
      return Container(color: color);
    }
    return QueuedNetworkImage.fromBungie(url, fit: BoxFit.cover);
  }

  Widget? buildWishlistTagBackground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final path = getWishlistBackgroundPath(context);
    if (path == null) return null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(width: _iconWidth),
        Expanded(
          child: Image.asset(
            path,
            fit: BoxFit.fitHeight,
          ),
        ),
      ],
    );
  }

  String? getWishlistBackgroundPath(BuildContext context) {
    final itemHash = item.itemHash;
    final reusablePlugs = item.reusablePlugs;
    if (itemHash == null || reusablePlugs == null) return null;
    final tags = wishlistsService.getWishlistBuildTags(itemHash: itemHash, reusablePlugs: reusablePlugs);
    if (tags.isEmpty) return null;
    bool isPvE = tags.contains(WishlistTag.GodPVE) || tags.contains(WishlistTag.PVE);
    bool isPvP = tags.contains(WishlistTag.GodPVP) || tags.contains(WishlistTag.PVP);
    if (isPvE && isPvP) {
      return "assets/imgs/allaround-bg.png";
    }
    if (isPvE) {
      return "assets/imgs/pve-bg.png";
    }
    if (isPvP) {
      return "assets/imgs/pvp-bg.png";
    }
    return null;
  }

  Widget buildForeground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition?.isSubclass ?? false) return buildSubclassForeground(context, definition);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildTitleBarContents(context, definition),
        buildItemIcon(context, definition),
      ],
    );
  }

  Widget buildSubclassForeground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final subclassColor = definition?.talentGrid?.hudDamageType?.getColorLayer(context).layer0 ?? Colors.transparent;
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

  Widget buildItemIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition == null)
      return SizedBox(
        width: _iconWidth,
        height: _iconWidth,
      );
    return Container(
      padding: const EdgeInsets.all(2),
      width: _iconWidth,
      child: RepaintBoundary(child: InventoryItemIcon(item, borderSize: 1.5)),
    );
  }

  Widget buildTitleBarContents(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition?.isSubclass ?? false) return buildSubclassTitleBar(context, definition);
    return Container(
      height: _titleBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: buildItemName(context, definition)),
          if (definition?.isArmor ?? false) buildTotalStats(context, definition),
          buildCraftableInfo(context, definition),
          buildHeaderWishlistIcons(context, definition),
          buildHeaderTagIcons(context, definition),
          buildLockedIcon(context, definition),
          buildCharacterIcon(context, definition),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget buildSubclassTitleBar(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final subclassColor = definition?.talentGrid?.hudDamageType?.getColorLayer(context).layer0 ?? Colors.transparent;
    final bgColor = TinyColor.fromColor(subclassColor).darken(30).desaturate(5).color;
    final itemNotes = context.watch<ItemNotesBloc>();
    final customName = itemNotes.customNameFor(item.itemHash, item.instanceId)?.toUpperCase();
    final definitionName = definition?.displayProperties?.name?.toUpperCase();
    final itemName = (customName?.isNotEmpty ?? false) ? customName : definitionName;
    return Container(
      margin: const EdgeInsets.all(4).copyWith(
        right: 96,
        left: 0,
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withValues(alpha: 0)],
          stops: const [.6, .9],
        ),
      ),
      child: Text(
        itemName ?? "",
        style: context.textTheme.itemNameHighDensity,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }

  Widget buildItemName(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final itemNotes = context.watch<ItemNotesBloc>();
    final customName = itemNotes.customNameFor(item.itemHash, item.instanceId)?.toUpperCase();
    final definitionName = definition?.displayProperties?.name?.toUpperCase();
    final itemName = (customName?.isNotEmpty ?? false) ? customName : definitionName;
    return Container(
      padding: const EdgeInsets.only(left: 2, right: 4),
      child: Text(
        itemName ?? "",
        style: context.textTheme.itemNameMediumDensity.copyWith(
          color: definition?.inventory?.tierType?.getTextColor(context),
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }

  Widget? buildLockedIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final isLocked = item.state?.contains(ItemState.Locked) ?? false;
    if (!isLocked) return null;
    final style = context.textTheme.itemNameMediumDensity;
    return Container(
      margin: const EdgeInsets.only(right: 2),
      child: Icon(
        FontAwesomeIcons.lock,
        size: style.fontSize,
        color: definition?.inventory?.tierType?.getTextColor(context),
      ),
    );
  }

  Widget? buildCharacterIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (!showCharacterIcon) return null;
    final characterId = item.characterId;
    if (characterId != null) {
      final character = context.watch<ProfileBloc>().getCharacterById(characterId);
      final emblemHash = character?.character.emblemHash;
      if (emblemHash == null) return null;
      return Container(
        margin: const EdgeInsets.only(right: 2),
        width: _titleBarIconSize,
        height: _titleBarIconSize,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(emblemHash),
      );
    }
    return null;
  }

  Widget? buildHeaderWishlistIcons(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final itemHash = item.itemHash;
    final reusablePlugs = item.reusablePlugs;
    if (itemHash == null || reusablePlugs == null) return null;
    final tags = wishlistsService.getWishlistBuildTags(itemHash: itemHash, reusablePlugs: reusablePlugs);
    if (tags.isEmpty) return null;
    return Row(
      children: tags
          .map((tag) {
            final color = tag.getColor(context);
            final borderColor = tag.getBorderColor(context);
            final icon = tag.getIcon(context);
            return Container(
              margin: const EdgeInsets.only(right: 2),
              width: _titleBarIconSize,
              height: _titleBarIconSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1, color: borderColor),
              ),
              child: Icon(icon, size: context.textTheme.itemNameMediumDensity.fontSize),
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
              margin: const EdgeInsets.only(right: 2),
              width: _titleBarIconSize,
              height: _titleBarIconSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(width: 1.0, color: borderColor ?? color ?? Colors.transparent),
              ),
              child: Icon(icon, size: context.textTheme.itemNameMediumDensity.fontSize, color: foregroundColor),
            );
          })
          .whereType<Widget>()
          .toList(),
    );
  }

  Widget buildMainContent(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition == null) return Container();
    if (definition.isWeapon) {
      return buildWeaponMainContent(context, definition);
    }
    if (definition.isArmor) {
      return buildArmorMainContent(context, definition);
    }
    if (definition.isGhost) {
      return buildGhostMainContent(context, definition);
    }
    if (definition.isSubclass) {
      return Container();
    }
    if (definition.isEngram) {
      return buildEngramMainContent(context, definition);
    }
    if (definition.isQuestStep) {
      return buildQuestStepMainContent(context, definition);
    }

    final isStack = (definition.inventory?.maxStackSize ?? 0) > 1;
    if (isStack) {
      return buildStackableMainContent(context, definition);
    }

    return buildDefaultMainContent(context, definition);
  }

  Widget buildWeaponMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 2, right: 2, bottom: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildWeaponMainInfo(context, definition),
          buildMods(context, definition),
        ],
      ),
    );
  }

  Widget buildArmorMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 2, right: 2, bottom: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildArmorMainInfo(context, definition),
          buildMods(context, definition),
        ],
      ),
    );
  }

  Widget buildGhostMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 2, right: 2, bottom: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildGhostMainInfo(context, definition),
          buildMods(context, definition),
        ],
      ),
    );
  }

  Widget buildDefaultMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 2, right: 2, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildPrimaryStat(context, definition),
          buildMods(context, definition),
        ],
      ),
    );
  }

  Widget buildEngramMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 2, right: 2, bottom: 2),
      alignment: Alignment.topRight,
      child: buildEngramMainInfo(context, definition),
    );
  }

  Widget buildQuestStepMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(left: 50, top: 2, right: 2, bottom: 2),
      alignment: Alignment.topRight,
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          alignment: Alignment.centerRight,
          child: buildExpiryDate(context, definition),
        ),
        buildObjectives(context, definition),
      ]),
    );
  }

  Widget buildExpiryDate(BuildContext context, DestinyInventoryItemDefinition definition) {
    final expiryDate = item.expirationDate;
    if (expiryDate == null) return Container();
    final isValid = DateTime.tryParse(expiryDate) != null;
    if (!isValid) return Container();
    final isObjectiveComplete = item.objectives?.objectives?.every((o) => o.complete ?? false) ?? false;
    if (isObjectiveComplete) return Container();
    return ShortExpiryDateWidget(expiryDate);
  }

  Widget buildObjectives(BuildContext context, DestinyInventoryItemDefinition definition) {
    final objectiveHashes = definition.objectives?.objectiveHashes;
    if (objectiveHashes == null) return Container();
    return MultiObjectiveProgressWidget(
      objectiveHashes,
      objectives: item.objectives?.objectives,
    );
  }

  Widget buildWeaponMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final damageType = item.damageType;
    final damageColor = damageType?.getColorLayer(context).layer2;
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatMediumDensity;
    final ammoType = definition.equippingBlock?.ammoType;
    return Container(
        height: 20,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                ammoType?.icon,
                color: ammoType?.color,
                size: textStyle.fontSize,
              ),
            ),
            Text(
              "$powerLevel",
              style: textStyle.copyWith(color: damageColor),
              softWrap: false,
            ),
          ],
        ));
  }

  Widget buildArmorMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatMediumDensity;
    return Container(
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: _iconWidth),
          Expanded(
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              buildArmorCategory(context, definition),
              Container(width: 2),
              Flexible(
                child: Text(
                  "$powerLevel",
                  style: textStyle,
                  softWrap: false,
                  textAlign: TextAlign.right,
                ),
              ),
            ]),
          ),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget buildGhostMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      height: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: _iconWidth),
          Expanded(
            child: Container(
              alignment: Alignment.centerRight,
              child: buildArmorCategory(context, definition),
            ),
          ),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget buildPrimaryStat(BuildContext context, DestinyInventoryItemDefinition definition) {
    final primaryStatValue = item.primaryStatValue;
    if (primaryStatValue == null) return Container();
    final textStyle = context.textTheme.itemPrimaryStatMediumDensity;
    return Container(
      height: 20,
      child: Text(
        "$primaryStatValue",
        style: textStyle,
        softWrap: false,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget buildStackableMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      alignment: Alignment.bottomRight,
      child: buildQuantity(context, definition),
    );
  }

  Widget buildQuantity(BuildContext context, DestinyInventoryItemDefinition definition) {
    final quantity = item.quantity;
    final maxCount = definition.inventory?.maxStackSize;
    TextStyle? textStyle = context.textTheme.itemPrimaryStatMediumDensity;
    final isMaxValue = maxCount != null && quantity == maxCount;
    if (isMaxValue) {
      textStyle = textStyle.copyWith(color: context.theme.highlightedObjectiveLayers.layer3);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("$quantity", style: textStyle, softWrap: false, textAlign: TextAlign.right),
        Text("/$maxCount",
            style: context.textTheme.caption.copyWith(color: context.theme.achievementLayers.layer2),
            softWrap: false,
            textAlign: TextAlign.right)
      ],
    );
  }

  Widget? buildEngramMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final itemLevel = item.itemLevel;
    final quality = item.quality ?? 0;
    if (itemLevel == null) return null;
    final level = itemLevel * 10 + quality;
    final textStyle = context.textTheme.itemPrimaryStatHighDensity;
    return Text(
      "$level",
      style: textStyle,
    );
  }

  Widget? buildTotalStats(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final total = item.stats?.values.fold<int>(0, (t, stat) => t + (stat.value ?? 0));
    if (total == null) return null;
    final color = getStatsTotalColor(total, context);
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
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

  Widget? buildCraftableInfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (item.state?.contains(ItemState.Crafted) ?? false) {
      return buildCraftedLevel(context, definition);
    }
    return buildPatternProgress(context, definition);
  }

  Widget? buildCraftedLevel(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final craftableObjectives =
        context.select<CraftablesHelperBloc, List<DestinyObjectiveProgress>?>((p) => p.getItemCraftedObjectives(item));
    final level = craftableObjectives?.elementAtOrNull(1)?.progress;
    if (level == null) return null;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer1,
          border: Border.all(color: context.theme.highlightedObjectiveLayers),
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.only(right: 4),
        child: Text(
          "Lv{level}".translate(context, replace: {"level": " $level"}),
          style: context.textTheme.caption.copyWith(
            color: context.theme.highlightedObjectiveLayers.layer1,
            height: 1,
          ),
        ));
  }

  Widget? buildPatternProgress(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final recipeHash = definition?.inventory?.recipeItemHash;
    final itemHash = definition?.hash;
    if (itemHash == null) return null;
    if (recipeHash == null || recipeHash == 0) return null;
    final patternProgress =
        context.select<CraftablesHelperBloc, DestinyRecordComponent?>((p) => p.getPatternProgressRecord(itemHash));
    if (patternProgress == null) return null;
    final progress = patternProgress.objectives?.firstOrNull?.progress;
    final total = patternProgress.objectives?.firstOrNull?.completionValue;
    return Container(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer1,
          border: Border.all(color: context.theme.highlightedObjectiveLayers),
          borderRadius: BorderRadius.circular(4),
        ),
        margin: EdgeInsets.only(right: 4),
        child: Text(
          "$progress / $total",
          style: context.textTheme.caption.copyWith(
            color: context.theme.highlightedObjectiveLayers.layer1,
            height: 1,
          ),
        ));
  }

  Widget buildArmorCategory(BuildContext context, DestinyInventoryItemDefinition definition) {
    return FutureBuilder<DestinyEnergyCapacityEntry?>(
        future: getEnergyCapacity(manifest, item, definition),
        builder: (context, snapshot) {
          final capacity = snapshot.data;
          if (capacity == null) return Container();
          final energyLevel = capacity.capacityValue ?? 0;
          final textStyle = context.textTheme.itemPrimaryStatMediumDensity;
          return Container(
            child: Text(
              "$energyLevel",
              style: textStyle,
            ),
          );
        });
  }

  Widget buildMods(BuildContext context, DestinyInventoryItemDefinition definition) {
    return FutureBuilder<int?>(
        future: getModsSocketCategory(manifest, definition),
        builder: (context, snapshot) {
          final categoryHash = snapshot.data;
          if (categoryHash == null) return Container();
          return Container(
            height: 24,
            child: Stack(children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: InventoryItemMods(
                  item,
                  plugSize: 20,
                  plugMargin: const EdgeInsets.only(left: 1),
                  categoryHash: categoryHash,
                ),
              )
            ]),
          );
        });
  }
}
