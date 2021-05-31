import 'dart:math';

import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_material_requirement_set_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_socket_details.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_sockets/plug_wishlist_tag_icons.mixin.dart';
import 'package:little_light/widgets/item_sockets/selectable_perk.widget.dart';
import 'package:little_light/widgets/item_stats/item_details_socket_item_stats.widget.dart';

class ItemDetailsSocketDetailsWidget extends BaseSocketDetailsWidget {
  ItemDetailsSocketDetailsWidget(
      {DestinyItemComponent item,
      DestinyItemSocketCategoryDefinition category,
      DestinyInventoryItemDefinition parentDefinition,
      ItemSocketController controller})
      : super(
            item: item,
            definition: parentDefinition,
            category: category,
            controller: controller);

  @override
  ItemDetailsSocketDetailsWidgetState createState() =>
      ItemDetailsSocketDetailsWidgetState();
}

class ItemDetailsSocketDetailsWidgetState
    extends BaseSocketDetailsWidgetState<ItemDetailsSocketDetailsWidget>
    with PlugWishlistTagIconsMixin {
  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    if (!(category?.socketIndexes?.contains(controller.selectedSocketIndex) ??
        false)) {
      return Container();
    }
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildOptions(context),
              buildHeader(context),
              Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.black,
                  child: buildContent(context)),
              buildResourceCost(context),
            ]));
  }

  buildHeader(BuildContext context) {
    Color bgColor = DestinyData.perkColor;
    return Container(
      color: bgColor,
      padding: EdgeInsets.all(8),
      child: Row(children: [
        Container(
            width: 48,
            height: 48,
            child: QueuedNetworkImage(
                imageUrl:
                    BungieApiService.url(definition?.displayProperties?.icon))),
        Container(width: 8),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              definition?.displayProperties?.name?.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(definition?.itemTypeDisplayName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300))
          ],
        ))
      ]),
    );
  }

  buildContent(BuildContext context) {
    Iterable<Widget> items = [
      buildDescription(context),
      buildEnergyCost(context),
      buildSandBoxPerks(context),
      buildStats(context),
      buildObjectives(context),
      buildWishlistInfo(context),
    ];
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.toList());
  }

  buildStats(BuildContext context) {
    if (!shouldShowStats) return Container();
    return Column(children: [
      Divider(
        thickness: 1,
        color: Colors.white,
      ),
      ItemDetailSocketItemStatsWidget(
        plugDefinition: definition,
        definition: itemDefinition,
        item: item,
        socketController: widget.controller,
      )
    ]);
  }

  buildObjectives(BuildContext context) {
    var itemObjectives = widget.profile.getPlugObjectives(item?.itemInstanceId);
    if (!(itemObjectives?.containsKey("${definition.hash}") ?? false))
      return Container();
    var objectives = itemObjectives["${definition.hash}"];
    return Column(
        children: <Widget>[
      Divider(
        thickness: 1,
        color: Colors.white,
      )
    ]
            .followedBy(objectives.map((o) => ObjectiveWidget(
                  objective: o,
                )))
            .toList());
  }

  buildDescription(BuildContext context) {
    if ((definition?.displayProperties?.description?.length ?? 0) == 0)
      return Container();
    return Text(definition?.displayProperties?.description,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300));
  }

  Widget buildReusableMods(BuildContext context) {
    var plugs = controller.socketPlugHashes(controller.selectedSocketIndex);
    if ((plugs?.length ?? 0) <= 1) return Container();
    var screenWidth = MediaQuery.of(context).size.width - 16;
    var dividerMargin = min(screenWidth / 50, 8.0);
    return Container(
        padding: EdgeInsets.only(bottom: 16),
        child: Wrap(
            alignment: WrapAlignment.start,
            runSpacing: dividerMargin,
            spacing: dividerMargin,
            children: plugs
                .map(
                    (h) => buildMod(context, controller.selectedSocketIndex, h))
                .toList()));
  }

  Widget buildMod(BuildContext context, int socketIndex, int plugItemHash) {
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color borderColor =
        isSelected ? Colors.white : Colors.grey.shade300.withOpacity(.5);

    BorderSide borderSide = BorderSide(color: borderColor, width: 1);
    var def = controller.plugDefinitions[plugItemHash];
    var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    var energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    var canEquip = controller?.canEquip(socketIndex, plugItemHash);
    var screenWidth = MediaQuery.of(context).size.width - 16;

    return Container(
        width: min(64, screenWidth / 8),
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
                        top: 4,
                        right: 4,
                        child: Text(
                          "$energyCost",
                          style: TextStyle(fontSize: 12),
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

  Widget buildRandomPerks(BuildContext context) {
    var randomHashes =
        controller.randomizedPlugHashes(controller.selectedSocketIndex);
    if ((randomHashes?.length ?? 0) == 0) {
      return Container();
    }
    var plugs = controller.socketPlugHashes(controller.selectedSocketIndex);
    plugs.addAll(randomHashes);
    var screenWidth = MediaQuery.of(context).size.width - 16;
    var dividerMargin = min(screenWidth / 50, 8.0);
    return Container(
        padding: EdgeInsets.only(bottom: 8),
        child: Wrap(
          runSpacing: dividerMargin,
          spacing: dividerMargin,
          children: plugs
              .map((h) => buildPerk(context, controller.selectedSocketIndex, h))
              .toList(),
        ));
  }

  @override
  Widget buildEnergyCost(BuildContext context) {
    var cost = definition?.plug?.energyCost;
    if (cost != null) {
      var color = DestinyData.getEnergyTypeLightColor(cost.energyType);
      var icon = cost.energyType == DestinyEnergyType.Any
          ? Container()
          : Icon(
              DestinyData.getEnergyTypeIcon(cost.energyType),
              color: color,
              size: 20,
            );
      var value = Container(
          padding: EdgeInsets.all(4),
          child: Text("${cost.energyCost}",
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 24, color: color)));
      var description = TranslatedTextWidget(
        "Energy Cost",
        uppercase: true,
        style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
      );
      return Row(children: <Widget>[icon, value, description]);
    }
    return Container();
  }

  Widget buildResourceCost(BuildContext context) {
    var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    if (requirementHash != null) {
      return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(
          requirementHash,
          (def) => Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                    top: BorderSide(color: Colors.grey.shade500, width: 1)),
              ),
              padding: EdgeInsets.all(8),
              child: Column(
                children:
                    def.materials.where((m) => (m.count ?? 0) > 0).map((m) {
                  return Row(
                    children: <Widget>[
                      Container(
                          width: 20,
                          height: 20,
                          child: ManifestImageWidget<
                              DestinyInventoryItemDefinition>(m.itemHash)),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 8),
                          child: ManifestText<DestinyInventoryItemDefinition>(
                            m.itemHash,
                            style: TextStyle(fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                      Text("${m.count}",
                          style: TextStyle(fontWeight: FontWeight.w300))
                    ],
                  );
                }).toList(),
              )),
          key: Key("material_requirements_$requirementHash"));
    }
    return Container();
  }

  Widget buildPerk(BuildContext context, int socketIndex, int plugItemHash) {
    var plugDef = controller.plugDefinitions[plugItemHash];
    int equippedHash = controller.socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    bool isSelectedOnSocket =
        plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
        width: min(64, screenWidth / 8),
        child: SelectablePerkWidget(
          selected: isSelected,
          selectedOnSocket: isSelectedOnSocket,
          itemDefinition: widget.definition,
          plugHash: plugItemHash,
          plugDefinition: plugDef,
          equipped: isEquipped,
          key: Key("$plugItemHash $isSelected $isSelectedOnSocket"),
          onTap: () {
            controller.selectSocket(socketIndex, plugItemHash);
          },
        ));
  }
}
