import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/craftables_helper.bloc.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/item_info/inventory_item_info.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import 'package:little_light/shared/utils/extensions/element_type_data.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/shared/utils/extensions/wishlist_tag_data.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/shared/widgets/character/postmaster_icon.widget.dart';
import 'package:little_light/shared/widgets/character/profile_icon.widget.dart';
import 'package:little_light/shared/widgets/character/vault_icon.widget.dart';
import 'package:little_light/shared/widgets/inventory_item/item_expiration_date.widget.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';
import 'package:little_light/shared/widgets/objectives/small_objective.widget.dart';
import 'package:little_light/shared/widgets/shapes/diamond_shape.dart';
import 'package:little_light/shared/widgets/tags/tag_icon.widget.dart';
import 'package:little_light/utils/color_utils.dart';
import 'package:little_light/utils/stats_total.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor2/tinycolor2.dart';
import 'inventory_item_icon.dart';
import 'inventory_item_mods.dart';
import 'inventory_item_perks.dart';
import 'inventory_item_stats.dart';
import 'utils/get_energy_capacity.dart';
import 'utils/get_mods_socket_category.dart';
import 'utils/get_perks_socket_category.dart';
import 'utils/get_subclass_mods_socket_category.dart';
import 'utils/get_subclass_super_plug_item.dart';

const _titleBarHeight = 32.0;
const _titleBarIconSize = 24.0;
const _iconWidth = 96.0;
const _primaryStatIconsSize = 18.0;

class HighDensityInventoryItem extends StatelessWidget with WishlistsConsumer, ManifestConsumer {
  final DestinyItemInfo item;
  final bool showCharacterIcon;
  const HighDensityInventoryItem(
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
    return Stack(
      fit: StackFit.expand,
      children: [
        buildBackground(context, definition),
        buildForeground(context, definition),
      ],
    );
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
      child: Container(
        constraints: const BoxConstraints(minHeight: double.infinity),
        foregroundDecoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [bgColor.withOpacity(0), bgColor],
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
    );
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
    final theme = LittleLightTheme.of(context);
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildItemIcon(context, definition),
        Container(
          width: 4,
        ),
        Expanded(
          child: Column(children: [
            buildTitleBarContents(context, definition),
            Expanded(
              child: buildMainContent(context, definition),
            )
          ]),
        ),
      ],
    );
  }

  Widget buildSubclassForeground(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final subclassColor = definition?.talentGrid?.hudDamageType?.getColorLayer(context).layer0 ?? Colors.transparent;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
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
            )),
        Expanded(
          child: Column(children: [
            buildTitleBarContents(context, definition),
            Expanded(child: Container()),
            buildMainContent(context, definition),
          ]),
        ),
      ],
    );
  }

  Widget buildItemIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition == null)
      return SizedBox(
        width: _iconWidth,
        height: _iconWidth,
      );
    return Container(
      padding: const EdgeInsets.all(4),
      width: _iconWidth,
      child: InventoryItemIcon(item),
    );
  }

  Widget buildTitleBarContents(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition?.isSubclass ?? false) return buildSubclassTitleBar(context, definition);
    return SizedBox(
      height: _titleBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: buildItemName(context, definition)),
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
        left: 0,
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0)],
          stops: const [.6, .7],
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
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        itemName ?? "",
        style: context.textTheme.itemNameHighDensity.copyWith(
          color: definition?.inventory?.tierType?.getTextColor(context),
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }

  Widget? buildCraftableInfo(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (item.state?.contains(ItemState.Crafted) ?? false) {
      return buildCraftLevel(context, definition);
    }
    return buildPatternProgress(context, definition);
  }

  Widget? buildCraftLevel(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final craftableObjectives =
        context.select<CraftablesHelperBloc, List<DestinyObjectiveProgress>?>((p) => p.getItemCraftedObjectives(item));
    final level = craftableObjectives?.elementAtOrNull(1)?.progress;
    if (level == null) return null;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        border: Border.all(color: context.theme.highlightedObjectiveLayers),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.only(right: 4),
      child: Row(children: [
        Text(
          "Lv{level}".translate(context, replace: {"level": " $level"}),
          style: context.textTheme.caption.copyWith(
            color: context.theme.highlightedObjectiveLayers.layer1,
            height: 1,
            fontWeight: FontWeight.bold,
          ),
        )
      ]),
    );
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
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        border: Border.all(color: context.theme.highlightedObjectiveLayers),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.only(right: 4),
      child: Row(children: [
        Container(margin: EdgeInsets.only(right: 4), width: 10, child: Image.asset("assets/imgs/deepsight.png")),
        Text(
          "$progress / $total",
          style: context.textTheme.caption.copyWith(
            color: context.theme.highlightedObjectiveLayers.layer1,
            height: 1,
            fontWeight: FontWeight.bold,
          ),
        )
      ]),
    );
  }

  Widget? buildLockedIcon(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final isLocked = item.state?.contains(ItemState.Locked) ?? false;
    if (!isLocked) return null;
    final style = context.textTheme.itemNameHighDensity;
    return Container(
      margin: const EdgeInsets.only(right: 4),
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
    final character = context.watch<ProfileBloc>().getCharacterById(characterId);
    if (character != null) {
      if (item.bucketHash == InventoryBucket.lostItems) {
        return Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 4),
              width: _titleBarIconSize,
              height: _titleBarIconSize,
              child: PostmasterIconWidget(
                borderWidth: .5,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4),
              width: _titleBarIconSize,
              height: _titleBarIconSize,
              child: CharacterIconWidget(
                character,
                borderWidth: .5,
                hideClassIcon: true,
              ),
            ),
          ],
        );
      }
      return Container(
        margin: const EdgeInsets.only(right: 4),
        width: _titleBarIconSize,
        height: _titleBarIconSize,
        child: CharacterIconWidget(
          character,
          borderWidth: .5,
          hideClassIcon: true,
        ),
      );
    }
    if (item.bucketHash == InventoryBucket.general) {
      return Container(
        margin: const EdgeInsets.only(right: 4),
        width: _titleBarIconSize,
        height: _titleBarIconSize,
        child: VaultIconWidget(
          borderWidth: .5,
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(right: 4),
      width: _titleBarIconSize,
      height: _titleBarIconSize,
      child: ProfileIconWidget(
        borderWidth: .5,
      ),
    );
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
              margin: const EdgeInsets.only(right: 4),
              width: _titleBarIconSize,
              height: _titleBarIconSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(width: 1.5, color: borderColor),
              ),
              child: Icon(icon, size: 18),
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
            return Container(
              margin: const EdgeInsets.only(right: 4),
              child: TagIconWidget.fromTag(tag),
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
      return buildSubclassMainContent(context, definition);
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
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildItemTypeName(context, definition)),
            buildWeaponMainInfo(context, definition),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: buildPerks(context, definition)),
              buildMods(context, definition),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildArmorMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildItemTypeName(context, definition)),
            buildArmorMainInfo(context, definition),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: buildStats(context, definition)),
              buildMods(context, definition),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildGhostMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildItemTypeName(context, definition)),
            buildGhostMainInfo(context, definition),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              buildMods(context, definition),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildQuestStepMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: buildItemTypeName(context, definition)),
              buildExpirationDate(context, definition),
            ],
          )),
          buildObjectiveProgress(context, definition),
        ],
      ),
    );
  }

  Widget buildDefaultMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildItemTypeName(context, definition)),
            buildPrimaryStat(context, definition),
          ],
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: buildPerks(context, definition)),
              buildMods(context, definition),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildStackableMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildItemTypeName(context, definition),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: buildStacks(context, definition) ?? Container()),
                buildQuantity(context, definition),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPrimaryStat(BuildContext context, DestinyInventoryItemDefinition definition) {
    final primaryStatValue = item.primaryStatValue;
    if (primaryStatValue == null) return Container();
    final textStyle = context.textTheme.itemPrimaryStatHighDensity;
    return Text(
      "$primaryStatValue",
      style: textStyle,
      softWrap: false,
      textAlign: TextAlign.right,
    );
  }

  Widget buildQuantity(BuildContext context, DestinyInventoryItemDefinition definition) {
    final quantity = item.quantity;
    final maxCount = definition.inventory?.maxStackSize;
    if (quantity == 1) return Container();
    TextStyle? textStyle = context.textTheme.itemPrimaryStatHighDensity;
    final text = maxCount != null ? "$quantity/$maxCount" : "x$quantity";
    final isMaxValue = maxCount != null && quantity == maxCount;
    if (isMaxValue) {
      textStyle = textStyle.copyWith(color: context.theme.highlightedObjectiveLayers.layer3);
    }
    return Text(
      text,
      style: textStyle,
      softWrap: false,
      textAlign: TextAlign.right,
    );
  }

  Widget? buildStacks(BuildContext context, DestinyInventoryItemDefinition definition) {
    final stacks = item.duplicates;
    if (stacks == null || stacks.isEmpty) return null;
    int inventoryCount = 0;
    int vaultCount = 0;
    int inventoryStackCount = 0;
    int vaultStackCount = 0;
    final style = context.textTheme.caption;
    for (final stack in stacks) {
      if (stack.bucketHash == InventoryBucket.general) {
        vaultCount += stack.quantity;
        vaultStackCount++;
      } else {
        inventoryCount += stack.quantity;
        inventoryStackCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (inventoryCount > 0)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                  width: 18,
                  height: 18,
                  child: ProfileIconWidget(
                    borderWidth: .5,
                  )),
              Container(width: 4),
              Text("$inventoryCount", style: style),
              Container(width: 4),
              if (inventoryStackCount > 1)
                Text("($inventoryStackCount)",
                    style: style.copyWith(color: context.theme.highlightedObjectiveLayers.layer0)),
            ],
          ),
        Container(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
                width: 18,
                height: 18,
                child: VaultIconWidget(
                  borderWidth: .5,
                )),
            Container(width: 4),
            Text("$vaultCount", style: style),
            Container(width: 4),
            if (vaultStackCount > 1)
              Text("($vaultStackCount)", style: style.copyWith(color: context.theme.highlightedObjectiveLayers.layer0)),
          ],
        ),
      ],
    );
  }

  Widget buildSubclassMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.all(4),
      alignment: Alignment.bottomLeft,
      child: buildSubclassMods(context, definition),
    );
  }

  Widget buildEngramMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: buildItemTypeName(context, definition)),
          buildEngramMainInfo(context, definition),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget buildExpirationDate(BuildContext context, DestinyInventoryItemDefinition definition) {
    final expirationDate = item.expirationDate;
    if (expirationDate == null) return Container();
    final isDate = DateTime.tryParse(expirationDate) != null;
    if (!isDate) return Container();
    final isObjectiveComplete = item.objectives?.objectives?.every((o) => o.complete ?? false) ?? false;
    if (isObjectiveComplete) return Container();
    return ExpiryDateWidget(expirationDate);
  }

  Widget buildItemTypeName(BuildContext context, DestinyInventoryItemDefinition definition) {
    final itemTypeName = definition.itemTypeDisplayName;
    if (itemTypeName == null) return Container();
    return Text(
      itemTypeName,
      style: context.textTheme.caption,
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  Widget buildWeaponMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final damageType = item.damageType;
    final damageColor = damageType?.getColorLayer(context).layer2;
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatHighDensity;
    final ammoType = definition.equippingBlock?.ammoType;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            ammoType?.icon,
            color: ammoType?.color,
            size: _primaryStatIconsSize,
          ),
        ),
        Icon(
          damageType?.icon,
          size: _primaryStatIconsSize,
          color: damageColor,
        ),
        if (powerLevel != null)
          Text(
            "$powerLevel",
            style: textStyle.copyWith(color: damageColor),
          ),
      ],
    );
  }

  Widget buildArmorMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final powerLevel = item.primaryStatValue;
    final textStyle = context.textTheme.itemPrimaryStatHighDensity;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildEnergyCapacity(context, definition),
        buildTotalStats(context, definition),
        if (powerLevel != null)
          Container(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              "$powerLevel",
              style: textStyle,
            ),
          ),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildGhostMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    return buildEnergyCapacity(context, definition);
  }

  Widget? buildEngramMainInfo(BuildContext context, DestinyInventoryItemDefinition definition) {
    final item = this.item;
    if (item is InventoryItemInfo) {
      final itemLevel = item.instanceInfo?.itemLevel;
      final quality = item.instanceInfo?.quality ?? 0;
      if (itemLevel == null) return null;
      final level = itemLevel * 10 + quality;
      final textStyle = context.textTheme.itemPrimaryStatHighDensity;
      return Text(
        "$level",
        style: textStyle,
      );
    }
    return Container();
  }

  Widget? buildTotalStats(BuildContext context, DestinyInventoryItemDefinition definition) {
    final total = item.stats?.values.fold<int>(0, (t, stat) => t + (stat.value ?? 0));
    if (total == null) return null;
    final color = getStatsTotalColor(total, context);
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer0,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "T{statsTotal}".translate(context, replace: {"statsTotal": "$total"}),
        style: context.textTheme.subtitle.copyWith(
          color: color,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget buildEnergyCapacity(BuildContext context, DestinyInventoryItemDefinition definition) {
    return FutureBuilder<DestinyEnergyCapacityEntry?>(
        future: getEnergyCapacity(manifest, item, definition),
        builder: (context, snapshot) {
          final capacity = snapshot.data;
          if (capacity == null) return Container();
          final energyLevel = capacity.capacityValue ?? 0;
          final textStyle = context.textTheme.itemPrimaryStatHighDensity;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 20, child: Image.asset('assets/imgs/energy-type-icon.png')),
              Text(
                "$energyLevel",
                style: textStyle,
              ),
            ],
          );
        });
  }

  Widget buildPerks(BuildContext context, DestinyInventoryItemDefinition definition) {
    return FutureBuilder<int?>(
        future: getPerksSocketCategory(manifest, definition),
        builder: (context, snapshot) {
          final categoryHash = snapshot.data;
          if (categoryHash == null) return Container();
          return Stack(children: [
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                child: InventoryItemPerks(
                  item,
                  categoryHash: categoryHash,
                ),
              ),
            )
          ]);
        });
  }

  Widget buildMods(BuildContext context, DestinyInventoryItemDefinition definition) {
    return FutureBuilder<int?>(
        future: getModsSocketCategory(manifest, definition),
        builder: (context, snapshot) {
          final categoryHash = snapshot.data;
          if (categoryHash == null) return Container();
          return InventoryItemMods(
            item,
            categoryHash: categoryHash,
            plugMargin: const EdgeInsets.only(left: 1),
          );
        });
  }

  Widget buildObjectiveProgress(BuildContext context, DestinyInventoryItemDefinition? definition) {
    final objectiveHashes = definition?.objectives?.objectiveHashes;
    if (objectiveHashes == null || objectiveHashes.isEmpty) return Container();
    if (objectiveHashes.length == 1) {
      final objectiveHash = objectiveHashes.first;
      final objective =
          item.objectives?.objectives?.firstWhereOrNull((objective) => objective.objectiveHash == objectiveHash);
      return ObjectiveWidget(
        objectiveHash,
        objective: objective,
        placeholder: definition?.displayProperties?.description,
      );
    }
    return Row(
      children: objectiveHashes.map((objectiveHash) {
        final objective =
            item.objectives?.objectives?.firstWhereOrNull((objective) => objective.objectiveHash == objectiveHash);
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: SmallObjectiveWidget(
              objectiveHash,
              objective: objective,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildSubclassMods(BuildContext context, DestinyInventoryItemDefinition definition) {
    return FutureBuilder<List<DestinySocketCategoryDefinition>?>(
        future: getSubclassModsSocketCategory(manifest, definition),
        builder: (context, snapshot) {
          final categories = snapshot.data;
          if (categories == null) return Container();
          return Container(
              height: 42,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Row(
                        children: categories //
                            .map((c) {
                              final hash = c.hash;
                              if (hash == null) return null;
                              final categoryName = c.displayProperties?.name?.toUpperCase();
                              return Container(
                                color: Colors.black.withOpacity(.5),
                                margin: const EdgeInsets.only(right: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (categoryName != null)
                                      Container(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: Text(
                                          categoryName,
                                          style: const TextStyle(fontSize: 9),
                                        ),
                                      ),
                                    InventoryItemMods(
                                      item,
                                      plugSize: 24,
                                      categoryHash: c.hash ?? 0,
                                    ),
                                  ],
                                ),
                              );
                            })
                            .whereType<Widget>()
                            .toList()),
                  )
                ],
              ));
        });
  }

  Widget buildStats(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Stack(children: [
      Positioned(
        left: 0,
        bottom: 0,
        child: InventoryItemStats(
          item,
        ),
      ),
    ]);
  }
}
