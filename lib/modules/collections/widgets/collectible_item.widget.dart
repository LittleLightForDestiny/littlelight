import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/inventory_item/interactive_item_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/shared/utils/extensions/ammo_type_data.dart';
import 'package:little_light/shared/utils/extensions/element_type_data.dart';
import 'package:little_light/shared/utils/extensions/inventory_item_data.dart';
import 'package:little_light/shared/utils/extensions/tier_type_data.dart';
import 'package:little_light/utils/color_utils.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/core/blocs/profile/craftables_helper.bloc.dart';

const _titleBarHeight = 32.0;
const _iconWidth = 96.0;
const _primaryStatIconsSize = 18.0;
const _titleBarIconsSize = 24.0;

class CollectibleItemWidget extends StatelessWidget {
  final int? collectibleHash;
  final DestinyItemInfo? genericItem;
  final List<DestinyItemInfo>? items;
  final bool isUnlocked;
  const CollectibleItemWidget(
    this.collectibleHash, {
    Key? key,
    this.items,
    this.genericItem,
    this.isUnlocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<SelectionBloc>();
    final items = this.items;
    final selected = items != null && items.isNotEmpty && items.every((i) => selection.isItemSelected(i));
    return Opacity(
        opacity: isUnlocked ? 1 : .7,
        child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: context.theme.surfaceLayers.layer3, width: 1),
                gradient: LinearGradient(begin: const Alignment(0, 0), end: const Alignment(1, 2), colors: [
                  context.theme.onSurfaceLayers.withValues(alpha: .05),
                  context.theme.onSurfaceLayers.withValues(alpha: .1),
                  context.theme.onSurfaceLayers.withValues(alpha: .03),
                  context.theme.onSurfaceLayers.withValues(alpha: .1)
                ])),
            child: Stack(children: [
              buildItem(context),
              Positioned.fill(
                  child: InteractiveItemWrapper(
                Container(),
                item: genericItem,
                overrideSelection: selected,
              )),
            ])));
  }

  Widget buildItem(BuildContext context) {
    DestinyInventoryItemDefinition? itemDefinition;
    final itemHash = genericItem?.itemHash;
    if (itemHash != null) itemDefinition = context.definition<DestinyInventoryItemDefinition>(itemHash);
    if (itemDefinition != null) return buildWithDefinition(context, itemDefinition);
    final collectibleDefinition = context.definition<DestinyCollectibleDefinition>(collectibleHash);
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Row(children: [
            buildIcon(context, itemDefinition),
            Container(
              alignment: Alignment.center,
              child: Text(
                collectibleDefinition?.displayProperties?.name ?? "Redacted".translate(context),
                style: context.textTheme.itemNameHighDensity,
              ),
            ),
          ]),
          Positioned(right: 0, top: 4, child: buildUnavailable(context)),
        ],
      ),
    );
  }

  Widget buildWithDefinition(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Stack(
      fit: StackFit.expand,
      children: [
        buildBackground(context, definition),
        buildForeground(context, definition),
      ],
    );
  }

  Widget buildBackground(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Column(
      children: [
        buildTitleBarBackground(context, definition),
        Expanded(child: buildMainBackground(context, definition)),
      ],
    );
  }

  Widget buildTitleBarBackground(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Container(
      color: definition.inventory?.tierType?.getColor(context),
      height: _titleBarHeight,
    );
  }

  Widget buildMainBackground(BuildContext context, DestinyInventoryItemDefinition definition) {
    if (definition.isEmblem) return buildEmblemMainBackground(context, definition);
    return Container(color: context.theme.surfaceLayers.layer1);
  }

  Widget buildEmblemMainBackground(BuildContext context, DestinyInventoryItemDefinition definition) {
    final url = definition.secondarySpecial;
    if (url == null) {
      final color = definition.backgroundColor?.toMaterialColor();
      return Container(color: color);
    }
    return QueuedNetworkImage.fromBungie(url, fit: BoxFit.cover);
  }

  Widget buildForeground(BuildContext context, DestinyInventoryItemDefinition definition) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildIcon(context, definition),
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

  Widget buildMainContent(BuildContext context, DestinyInventoryItemDefinition definition) {
    final collectibleDef = context.definition<DestinyCollectibleDefinition>(collectibleHash);
    final sourceString = collectibleDef?.sourceString ?? "";
    return Container(
      padding: const EdgeInsets.only(top: 4, right: 4, bottom: 4),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildItemTypeName(context, definition)),
            if (definition.isWeapon) buildWeaponMainInfo(context, definition),
          ],
        ),
        Expanded(
          child: Container(
              padding: const EdgeInsets.only(bottom: 4),
              alignment: Alignment.bottomLeft,
              child: Text(
                sourceString,
                textAlign: TextAlign.left,
                style: context.textTheme.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )),
        ),
      ]),
    );
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
    final damageType = genericItem?.damageType;
    final damageColor = damageType?.getColorLayer(context).layer2;
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
      ],
    );
  }

  Widget buildIcon(BuildContext context, DestinyInventoryItemDefinition? itemDefinition) {
    String? iconImage = itemDefinition?.displayProperties?.icon;
    if (iconImage == null) {
      final collectibleDefinition = context.definition<DestinyCollectibleDefinition>(collectibleHash);
      iconImage = collectibleDefinition?.displayProperties?.icon;
    }
    return Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.only(right: 4),
        width: _iconWidth,
        height: _iconWidth,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: context.theme.onSurfaceLayers.layer1,
                width: 2,
              )),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: context.theme.surfaceLayers.layer0),
                  QueuedNetworkImage.fromBungie(iconImage, fit: BoxFit.cover),
                  buildSeasonOverlay(context, itemDefinition),
                ],
              )),
        ));
  }

  Widget buildSeasonOverlay(BuildContext context, DestinyInventoryItemDefinition? definition) {
    if (definition == null) return Container();
    final watermarkIcons = definition.quality?.displayVersionWatermarkIcons;
    String? badgeUrl;
    if (watermarkIcons == null) //
      badgeUrl = definition.iconWatermark ?? definition.iconWatermarkShelved;
    else if (watermarkIcons.length == 1) //
      badgeUrl = watermarkIcons[0];
    if (badgeUrl?.isEmpty ?? true) return Container();
    return QueuedNetworkImage.fromBungie(
      badgeUrl,
      fit: BoxFit.fill,
    );
  }

  Widget buildTitleBarContents(BuildContext context, DestinyInventoryItemDefinition definition) {
    return SizedBox(
      height: _titleBarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: buildItemName(context, definition)),
          buildPatternProgress(context, definition),
          buildUnavailable(context),
          buildItemCount(context),
        ].whereType<Widget>().toList(),
      ),
    );
  }

  Widget buildItemName(BuildContext context, DestinyInventoryItemDefinition definition) {
    final itemName = definition.displayProperties?.name?.toUpperCase();
    return Container(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        itemName ?? "",
        style: context.textTheme.itemNameHighDensity.copyWith(
          color: definition.inventory?.tierType?.getTextColor(context),
        ),
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
    );
  }

  Widget? buildPatternProgress(BuildContext context, DestinyInventoryItemDefinition definition) {
    final recipeHash = definition.inventory?.recipeItemHash;
    final itemHash = definition.hash;
    if (itemHash == null) return null;
    if (recipeHash == null || recipeHash == 0) return null;
    final patternProgress =
        context.select<CraftablesHelperBloc, DestinyRecordComponent?>((p) => p.getPatternProgressRecord(itemHash));
    if (patternProgress == null) return null;
    final progress = patternProgress.objectives?.firstOrNull?.progress;
    final total = patternProgress.objectives?.firstOrNull?.completionValue;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        border: Border.all(color: context.theme.highlightedObjectiveLayers),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.only(right: 6),
      child: Row(children: [
        Container(margin: const EdgeInsets.only(right: 4), width: 10, child: Image.asset("assets/imgs/deepsight.png")),
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

  Widget? buildItemCount(BuildContext context) {
    final total = items?.fold(0, (t, e) => t + e.quantity) ?? 0;
    if (total == 0) return null;
    return Container(
      constraints: BoxConstraints(minWidth: _titleBarIconsSize),
      padding: const EdgeInsets.only(left: 4, right: 4),
      margin: const EdgeInsets.only(right: 4),
      height: _titleBarIconsSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: context.theme.onSurfaceLayers,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(_titleBarIconsSize),
        color: context.theme.surfaceLayers.layer2.withValues(alpha: .8),
      ),
      alignment: Alignment.center,
      child: Text(
        "${total}",
        textAlign: TextAlign.center,
        style: context.textTheme.highlight,
      ),
    );
  }

  Widget buildUnavailable(BuildContext context) {
    final def = context.read<ProfileBloc>().getProfileCollectible(collectibleHash);
    if (def?.state?.contains(DestinyCollectibleState.Invisible) ?? false) {
      return Container(
          margin: const EdgeInsets.only(right: 4),
          width: _titleBarIconsSize,
          height: _titleBarIconsSize, //
          child: Icon(Icons.block, color: context.theme.highlightedObjectiveLayers));
    }
    return Container();
  }
}
