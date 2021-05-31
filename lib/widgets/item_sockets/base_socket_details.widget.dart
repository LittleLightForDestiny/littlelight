import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/enums/item_perk_visibility.dart';
import 'package:bungie_api/enums/tier_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_material_requirement_set_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_sandbox_perk_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';
import 'package:little_light/widgets/item_stats/item_details_socket_item_stats.widget.dart';

import 'item_socket.controller.dart';

class BaseSocketDetailsWidget extends BaseDestinyStatefulItemWidget {
  final ManifestService manifest = ManifestService();
  final ItemSocketController controller;
  final DestinyItemSocketCategoryDefinition category;

  BaseSocketDetailsWidget({
    Key key,
    DestinyInventoryItemDefinition definition,
    DestinyItemComponent item,
    this.controller,
    this.category,
  }) : super(key: key, item: item, definition: definition);

  @override
  State<StatefulWidget> createState() {
    return BaseSocketDetailsWidgetState();
  }
}

class BaseSocketDetailsWidgetState<T extends BaseSocketDetailsWidget>
    extends BaseDestinyItemState<T> with TickerProviderStateMixin {
  DestinyStatGroupDefinition _statGroupDefinition;
  ItemSocketController get controller => widget.controller;
  Map<int, DestinySandboxPerkDefinition> _sandboxPerkDefinitions;
  Map<int, DestinySandboxPerkDefinition> get sandboxPerkDefinitions =>
      _sandboxPerkDefinitions;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  DestinyInventoryItemDefinition _definition;
  DestinyInventoryItemDefinition get definition => _definition;
  DestinyInventoryItemDefinition get itemDefinition => widget.definition;
  DestinyItemSocketCategoryDefinition get category => widget.category;
  bool open = false;

  @override
  void initState() {
    super.initState();

    if (controller != null) controller.addListener(socketChanged);

    loadDefinitions();
  }

  void dispose() {
    if (controller != null) controller.removeListener(socketChanged);
    super.dispose();
  }

  socketChanged() async {
    await this.loadDefinitions();
  }

  Future<void> loadDefinitions() async {
    if ((controller.selectedPlugHash ?? 0) == 0) {
      _definition = null;
      if (mounted) {
        setState(() {});
      }
      return;
    }
    _definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(
            controller.selectedPlugHash);

    _sandboxPerkDefinitions = await widget.manifest
        .getDefinitions<DestinySandboxPerkDefinition>(
            _definition?.perks?.map((p) => p.perkHash)?.toList() ?? []);

    _statGroupDefinition = await widget.manifest
        .getDefinition<DestinyStatGroupDefinition>(
            itemDefinition?.stats?.statGroupHash);

    if ((definition?.objectives?.objectiveHashes?.length ?? 0) > 0) {
      objectiveDefinitions = await widget.manifest
          .getDefinitions<DestinyObjectiveDefinition>(
              definition.objectives.objectiveHashes);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.blueGrey.shade700,
            borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    child: QueuedNetworkImage(
                      imageUrl: BungieApiService.url(
                          definition?.displayProperties?.icon),
                    ),
                  ),
                  Container(
                    width: 8,
                  ),
                  Expanded(
                      child: Text(
                    definition?.displayProperties?.name ?? "",
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
              )),
            ],
          ),
          AnimatedCrossFade(
              crossFadeState:
                  open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              alignment: Alignment.topCenter,
              duration: Duration(milliseconds: 300),
              firstChild: Container(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        definition?.displayProperties?.description ?? "",
                      )),
                  buildStats(context),
                ],
              )),
        ]));
  }

  Widget buildOptions(BuildContext context) {
    var index = controller.selectedSocketIndex;
    var cat = itemDefinition?.sockets?.socketCategories?.firstWhere(
        (s) => s?.socketIndexes?.contains(index),
        orElse: () => null);

    var isExoticPerk = DestinyData.socketCategoryIntrinsicPerkHashes
        .contains(cat?.socketCategoryHash);
    if (isExoticPerk) {
      return Container();
    }

    var isPerk =
        DestinyData.socketCategoryPerkHashes.contains(cat?.socketCategoryHash);

    if (isPerk && controller.reusablePlugs != null) {
      return Container();
    }
    if (isPerk) {
      return buildRandomPerks(context);
    }
    return buildReusableMods(context);
  }

  Widget buildReusableMods(BuildContext context) {
    var plugs = controller.socketPlugHashes(controller.selectedSocketIndex);
    if ((plugs?.length ?? 0) <= 1) return Container();
    return Wrap(
        alignment: WrapAlignment.start,
        runSpacing: 10,
        spacing: 10,
        children: plugs
            .map((h) => buildMod(context, controller.selectedSocketIndex, h))
            .toList());
  }

  Widget buildRandomPerks(BuildContext context) {
    var randomHashes =
        controller.randomizedPlugHashes(controller.selectedSocketIndex);
    if ((randomHashes?.length ?? 0) == 0) {
      return Container(height: 80);
    }
    var plugs = controller.socketPlugHashes(controller.selectedSocketIndex);
    plugs.addAll(randomHashes);
    return Wrap(
      runSpacing: 6,
      spacing: 6,
      children: plugs
          .map((h) => buildPerk(context, controller.selectedSocketIndex, h))
          .toList(),
    );
  }

  Widget buildMod(BuildContext context, int socketIndex, int plugItemHash) {
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color borderColor =
        isSelected ? Colors.white : Colors.grey.shade300.withOpacity(.5);

    BorderSide borderSide = BorderSide(color: borderColor, width: 3);
    var def = controller.plugDefinitions[plugItemHash];
    var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    var energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    var canEquip = controller?.canEquip(socketIndex, plugItemHash);
    return Container(
        width: 96,
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: EdgeInsets.all(0),
        child: AspectRatio(
            aspectRatio: 1,
            child: MaterialButton(
              shape: ContinuousRectangleBorder(side: borderSide),
              padding: EdgeInsets.all(0),
              child: Stack(children: [
                ManifestImageWidget<DestinyInventoryItemDefinition>(
                    plugItemHash),
                energyType == DestinyEnergyType.Any
                    ? Container()
                    : Positioned.fill(
                        child: ManifestImageWidget<DestinyStatDefinition>(
                            DestinyData.getEnergyTypeCostHash(energyType))),
                energyCost == 0
                    ? Container()
                    : Positioned(
                        top: 8,
                        right: 8,
                        child: Text(
                          "$energyCost",
                          style: TextStyle(fontSize: 20),
                        )),
                canEquip
                    ? Container()
                    : Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(.5),
                        ),
                      )
              ]),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }

  Widget buildPerk(BuildContext context, int socketIndex, int plugItemHash) {
    var plugDef = controller.plugDefinitions[plugItemHash];
    bool intrinsic = plugDef?.plug?.plugCategoryIdentifier == "intrinsics";
    int equippedHash = controller.socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    bool isExotic = definition.inventory.tierType == TierType.Exotic;
    bool isSelectedOnSocket =
        plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey.shade300.withOpacity(.5);
    if (isEquipped && !intrinsic) {
      bgColor = DestinyData.perkColor.withOpacity(.5);
    }
    if (isSelectedOnSocket && !intrinsic) {
      bgColor = DestinyData.perkColor;
      borderColor = Colors.grey.shade300;
    }

    if (intrinsic && !isSelected) {
      borderColor = Colors.transparent;
    }

    BorderSide borderSide = BorderSide(color: borderColor, width: 2);

    return Container(
        width: 80,
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: EdgeInsets.all(0),
        child: AspectRatio(
            aspectRatio: 1,
            child: MaterialButton(
              shape: intrinsic && !isExotic
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), side: borderSide)
                  : CircleBorder(side: borderSide),
              padding: EdgeInsets.all(intrinsic ? 0 : 8),
              color: bgColor,
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  plugItemHash),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }

  Widget buildEnergyCost(BuildContext context) {
    var cost = definition?.plug?.energyCost;
    if (cost != null) {
      return Text("${cost.energyCost}");
    }
    return Container();
  }

  Widget buildResourceCost(BuildContext context) {
    var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    if (requirementHash != null) {
      return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(
          requirementHash,
          (def) => Column(
                children: def.materials.map((m) {
                  return Row(
                    children: <Widget>[
                      Container(
                          width: 20,
                          height: 20,
                          child: ManifestImageWidget<
                              DestinyInventoryItemDefinition>(m.itemHash)),
                      Container(
                        width: 20,
                      ),
                      Text("${m.count}")
                    ],
                  );
                }).toList(),
              ));
    }
    return Container();
  }

  buildStats(BuildContext context) {
    return ItemDetailSocketItemStatsWidget(
      definition: itemDefinition,
      plugDefinition: definition,
      item: item,
      socketController: controller,
    );
  }

  bool get shouldShowStats {
    var statWhitelist =
        _statGroupDefinition?.scaledStats?.map((s) => s.statHash)?.toList() ??
            [];
    List<int> statHashes = definition.investmentStats
            ?.map((s) => s.statTypeHash)
            ?.where((s) =>
                statWhitelist.contains(s) ||
                DestinyData.hiddenStats.contains(s))
            ?.toList() ??
        [];

    return statHashes.length > 0;
  }

  Widget buildSandBoxPerks(BuildContext context) {
    if (sandboxPerkDefinitions == null) return Container();
    var perks = definition?.perks?.where((p) {
      if (p.perkVisibility != ItemPerkVisibility.Visible) return false;
      var def = sandboxPerkDefinitions[p.perkHash];
      if ((def?.isDisplayable ?? false) == false) return false;
      return true;
    });
    if ((perks?.length ?? 0) == 0) return Container();
    return Column(
      children: perks
          ?.map((p) => Container(
              padding: EdgeInsets.symmetric(
                vertical: 8,
              ),
              child: Row(
                key: Key("mod_perk_${p.perkHash}"),
                children: <Widget>[
                  Container(
                    height: 36,
                    width: 36,
                    child: ManifestImageWidget<DestinySandboxPerkDefinition>(
                        p.perkHash),
                  ),
                  Container(
                    width: 8,
                  ),
                  Expanded(
                      child: ManifestText<DestinySandboxPerkDefinition>(
                    p.perkHash,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                    textExtractor: (def) => def.displayProperties?.description,
                  )),
                ],
              )))
          ?.toList(),
    );
  }

  Widget buildWishlistInfo(BuildContext context,
      [double iconSize = 16, double fontSize = 13]) {
    var tags =
        WishlistsService().getPerkTags(itemDefinition?.hash, definition.hash);
    if (tags == null) return Container();
    return buildWishlistTagsInfo((context),
        tags: tags, iconSize: iconSize, fontSize: fontSize);
  }

  Widget buildWishlistTagsInfo(BuildContext context,
      {double iconSize = 16, double fontSize = 13, Set<WishlistTag> tags}) {
    List<Widget> rows = [];
    if (tags.contains(WishlistTag.GodPVE) &&
        tags.contains(WishlistTag.GodPVP)) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: iconSize / 2),
          child: Row(children: [
            WishlistBadgeWidget(
                tags: [WishlistTag.GodPVE, WishlistTag.GodPVP].toSet(),
                size: iconSize),
            Container(
              width: 4,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This perk is considered the best for both PvE and PvP on this item.",
                    style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.w300)))
          ]));
    }
    if (tags.contains(WishlistTag.GodPVE)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.GodPVE].toSet(), size: iconSize),
        Container(
          width: 4,
        ),
        Expanded(
            child: TranslatedTextWidget(
                "This perk is considered the best for PvE on this item.",
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w300)))
      ])));
    }
    if (tags.contains(WishlistTag.GodPVP)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.GodPVP].toSet(), size: iconSize),
        Container(
          width: 4,
        ),
        Expanded(
            child: TranslatedTextWidget(
                "This perk is considered the best for PvP on this item.",
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w300)))
      ])));
    }
    if (tags.contains(WishlistTag.PVE) &&
        tags.contains(WishlistTag.PVP) &&
        rows.length == 0) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: iconSize / 2),
          child: Row(children: [
            WishlistBadgeWidget(
                tags: [WishlistTag.PVE, WishlistTag.PVP].toSet(),
                size: iconSize),
            Container(
              width: 4,
            ),
            Expanded(
                child: TranslatedTextWidget(
                    "This perk is considered good for both PvE and PvP on this item.",
                    style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.w300)))
          ]));
    }
    if (tags.contains(WishlistTag.PVE) && !tags.contains(WishlistTag.GodPVE)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.PVE].toSet(), size: iconSize),
        Container(
          width: 4,
        ),
        Expanded(
            child: TranslatedTextWidget(
                "This perk is considered good for PvE on this item.",
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w300)))
      ])));
    }
    if (tags.contains(WishlistTag.PVP) && !tags.contains(WishlistTag.GodPVP)) {
      rows.add(Container(
          child: Row(children: [
        WishlistBadgeWidget(tags: [WishlistTag.PVP].toSet(), size: iconSize),
        Container(
          width: 4,
        ),
        Expanded(
            child: TranslatedTextWidget(
                "This perk is considered good for PvP on this item.",
                style:
                    TextStyle(fontSize: fontSize, fontWeight: FontWeight.w300)))
      ])));
    }
    if (rows.length > 0) {
      return Container(
          padding: EdgeInsets.symmetric(vertical: iconSize / 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ));
    }
    return Container();
  }
}
