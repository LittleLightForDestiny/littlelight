// @dart=2.9

import 'dart:math';

import 'package:bungie_api/enums/destiny_energy_type.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_material_requirement_set_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_sockets/base_socket_details.widget.dart';
import 'package:little_light/widgets/item_sockets/item_socket.controller.dart';
import 'package:little_light/widgets/item_sockets/plug_grid_view.dart';
import 'package:little_light/widgets/item_sockets/plug_wishlist_tag_icons.mixin.dart';
import 'package:little_light/widgets/item_sockets/selectable_perk.widget.dart';
import 'package:little_light/widgets/item_stats/item_details_socket_item_stats.widget.dart';

class ItemDetailsSocketDetailsWidget extends BaseSocketDetailsWidget {
  const ItemDetailsSocketDetailsWidget(
      {DestinyItemComponent item,
      DestinyItemSocketCategoryDefinition category,
      DestinyInventoryItemDefinition parentDefinition,
      ItemSocketController controller})
      : super(item: item, definition: parentDefinition, category: category, controller: controller);

  @override
  ItemDetailsSocketDetailsWidgetState createState() => ItemDetailsSocketDetailsWidgetState();
}

class ItemDetailsSocketDetailsWidgetState extends BaseSocketDetailsWidgetState<ItemDetailsSocketDetailsWidget>
    with PlugWishlistTagIconsMixin, ProfileConsumer, ItemNotesConsumer {
  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    if (!(category?.socketIndexes?.contains(controller.selectedSocketIndex) ?? false)) {
      return Container();
    }
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          buildOptions(context),
          buildHeader(context),
          Container(padding: const EdgeInsets.all(8), color: Colors.black, child: buildContent(context)),
          buildResourceCost(context),
        ]));
  }

  buildHeader(BuildContext context) {
    Color bgColor = DestinyData.perkColor;
    return Material(
        color: bgColor,
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            SizedBox(
                width: 48,
                height: 48,
                child: QueuedNetworkImage(imageUrl: BungieApiService.url(definition?.displayProperties?.icon))),
            Container(width: 8),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  definition?.displayProperties?.name?.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(definition?.itemTypeDisplayName ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300))
              ],
            )),
            if (controller.isSocketFavoritable(controller.selectedSocketIndex)) buildFavoriteButton(context)
          ]),
        ));
  }

  Widget buildFavoriteButton(BuildContext context) {
    final isFavorite = itemNotes?.getNotesForItem(definition.hash, null)?.tags?.contains("favorite") ?? false;
    return IconButton(
        onPressed: () {
          final notes = itemNotes?.getNotesForItem(definition.hash, null, true);
          final isFavorite = notes?.tags?.contains("favorite") ?? false;
          isFavorite ? notes.tags.remove("favorite") : notes.tags.add("favorite");
          itemNotes.saveNotes(notes);
          setState(() {});
        },
        icon: Icon(isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart));
  }

  buildContent(BuildContext context) {
    Iterable<Widget> items = [
      buildDescription(context),
      buildEnergyCost(context),
      buildSandBoxPerks(context),
      buildStats(context),
      buildObjectives(context),
      buildWishlistInfo(context),
      buildApplyButton(context)
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: items.toList());
  }

  @override
  buildStats(BuildContext context) {
    if (!shouldShowStats) return Container();
    return Column(children: [
      Divider(
        thickness: 1,
        color: Theme.of(context).colorScheme.onSurface,
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
    var itemObjectives = profile.getPlugObjectives(item?.itemInstanceId);
    if (!(itemObjectives?.containsKey("${definition.hash}") ?? false)) return Container();
    var objectives = itemObjectives["${definition.hash}"];
    return Column(
        children: <Widget>[
      Divider(
        thickness: 1,
        color: Theme.of(context).colorScheme.onSurface,
      )
    ]
            .followedBy(objectives.map((o) => ObjectiveWidget(
                  objective: o,
                )))
            .toList());
  }

  buildDescription(BuildContext context) {
    if ((definition?.displayProperties?.description?.length ?? 0) == 0) return Container();
    return Text(definition?.displayProperties?.description,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300));
  }

  @override
  Widget buildReusableMods(BuildContext context) {
    final plugs = controller.socketPlugHashes(controller.selectedSocketIndex);

    return Container(
        padding: const EdgeInsets.only(bottom: 8),
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth - 32;
          final itemsPerRow = (width / 48).floor();
          final rowCount = (plugs.length / itemsPerRow).ceil().clamp(0, 3);
          final tabCount = (plugs.length / (itemsPerRow * rowCount)).ceil();
          final itemHeight = width / itemsPerRow;
          final gridHeight = itemHeight * rowCount - 8;

          return DefaultTabController(
              length: tabCount,
              child: SizedBox(
                height: gridHeight,
                child: Row(children: [
                  Builder(builder: (context) => pagingButton(context, -1)),
                  Expanded(
                      child: PlugGridView.withItemsPerRow(
                    plugs,
                    itemBuilder: (h) => buildMod(context, controller.selectedSocketIndex, h),
                    itemsPerRow: itemsPerRow,
                    maxRows: rowCount,
                    gridSpacing: 8,
                  )),
                  Builder(builder: (context) => pagingButton(context, 1)),
                ]),
              ));
        }));
  }

  Widget pagingButton(BuildContext context, [int direction = 1]) {
    final controller = DefaultTabController.of(context);
    final length = controller.length;

    return AnimatedBuilder(
        animation: controller.animation,
        builder: (context, child) {
          final currentIndex = controller.index;
          final enabled = direction < 0 ? currentIndex > 0 : currentIndex < length - 1;
          return Container(
            constraints: const BoxConstraints.expand(width: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
            padding: const EdgeInsets.all(0),
            alignment: Alignment.center,
            child: !enabled
                ? Container(color: Colors.grey.shade300.withOpacity(.2))
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () {
                          controller.animateTo(currentIndex + direction);
                        },
                        child: Container(
                            constraints: const BoxConstraints.expand(),
                            child: Icon(direction > 0 ? FontAwesomeIcons.caretRight : FontAwesomeIcons.caretLeft,
                                size: 16)))),
          );
        });
  }

  @override
  Widget buildMod(BuildContext context, int socketIndex, int plugItemHash) {
    bool isFavorite = itemNotes.getNotesForItem(plugItemHash, null)?.tags?.contains("favorite") ?? false;
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    Color borderColor =
        isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(.5);

    BorderSide borderSide = BorderSide(color: borderColor, width: isSelected ? 3 : 1);
    var def = controller.plugDefinitions[plugItemHash];
    var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    var energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    var canEquip = controller?.canEquip(socketIndex, plugItemHash);
    var screenWidth = MediaQuery.of(context).size.width - 16;

    return Container(
        width: min(64, screenWidth / 8),
        key: Key("plug_${socketIndex}_$plugItemHash"),
        padding: const EdgeInsets.all(0),
        child: AspectRatio(
            aspectRatio: 1,
            child: MaterialButton(
              shape: ContinuousRectangleBorder(side: borderSide),
              padding: const EdgeInsets.all(0),
              child: Stack(children: [
                ManifestImageWidget<DestinyInventoryItemDefinition>(plugItemHash),
                energyType == DestinyEnergyType.Any
                    ? Container()
                    : Positioned.fill(
                        child:
                            ManifestImageWidget<DestinyStatDefinition>(DestinyData.getEnergyTypeCostHash(energyType))),
                energyCost == 0
                    ? Container()
                    : Positioned(
                        top: 4,
                        right: 4,
                        child: Text(
                          "$energyCost",
                          style: const TextStyle(fontSize: 12),
                        )),
                canEquip
                    ? Container()
                    : Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(.5),
                        ),
                      ),
                if (isFavorite) const Positioned(right: 2, top: 2, child: Icon(FontAwesomeIcons.solidHeart, size: 10))
              ]),
              onPressed: () {
                controller.selectSocket(socketIndex, plugItemHash);
              },
            )));
  }

  @override
  Widget buildRandomPerks(BuildContext context) {
    final plugs = controller.possiblePlugHashes(controller.selectedSocketIndex);
    if (plugs?.isEmpty ?? false) {
      return Container();
    }
    var screenWidth = MediaQuery.of(context).size.width - 16;
    var dividerMargin = min(screenWidth / 50, 8.0);
    return Container(
        padding: const EdgeInsets.only(bottom: 8),
        child: Wrap(
          runSpacing: dividerMargin,
          spacing: dividerMargin,
          children: plugs.map((p) => buildPerk(context, controller.selectedSocketIndex, p)).toList(),
        ));
  }

  @override
  Widget buildEnergyCost(BuildContext context) {
    var cost = definition?.plug?.energyCost;
    if (cost != null) {
      final color = cost.energyType.getColorLayer(context).layer1;
      var icon = cost.energyType == DestinyEnergyType.Any
          ? Container()
          : Icon(
              DestinyData.getEnergyTypeIcon(cost.energyType),
              color: color,
              size: 20,
            );
      var value = Container(
          padding: const EdgeInsets.all(4),
          child: Text("${cost.energyCost}", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24, color: color)));
      var description = TranslatedTextWidget(
        "Energy Cost",
        uppercase: true,
        style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
      );
      return Row(children: <Widget>[icon, value, description]);
    }
    return Container();
  }

  @override
  Widget buildResourceCost(BuildContext context) {
    var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    if (requirementHash != null) {
      return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(requirementHash, (def) {
        final materials = def?.materials?.where((element) => (element.count ?? 0) > 0);
        if (materials?.isEmpty ?? true) {
          return Container();
        }
        return Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(top: BorderSide(color: Colors.grey.shade500, width: 1)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: materials.map((m) {
                return Row(
                  children: <Widget>[
                    SizedBox(
                        width: 20, height: 20, child: ManifestImageWidget<DestinyInventoryItemDefinition>(m.itemHash)),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 8),
                        child: ManifestText<DestinyInventoryItemDefinition>(
                          m.itemHash,
                          style: const TextStyle(fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                    Text("${m.count}", style: const TextStyle(fontWeight: FontWeight.w300))
                  ],
                );
              }).toList(),
            ));
      }, key: Key("material_requirements_$requirementHash"));
    }
    return Container();
  }

  @override
  Widget buildPerk(BuildContext context, int socketIndex, int plugItemHash) {
    var plugDef = controller.plugDefinitions[plugItemHash];
    int equippedHash = controller.socketEquippedPlugHash(socketIndex);
    bool isEquipped = equippedHash == plugItemHash;
    bool isSelectedOnSocket = plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    bool isSelected = plugItemHash == controller.selectedPlugHash;
    bool canRoll = controller.item != null || controller.canRollPerk(socketIndex, plugItemHash);
    var screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
        width: min(64, screenWidth / 8),
        child: SelectablePerkWidget(
          selected: isSelected,
          selectedOnSocket: isSelectedOnSocket,
          itemDefinition: widget.definition,
          plugHash: plugItemHash,
          plugDefinition: plugDef,
          equipped: isEquipped,
          canRoll: canRoll,
          key: Key("$plugItemHash $isSelected $isSelectedOnSocket"),
          onTap: () {
            controller.selectSocket(socketIndex, plugItemHash);
          },
        ));
  }

  Widget buildApplyButton(BuildContext context) {
    var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    final isApplied = controller.selectedPlugHash == controller.socketEquippedPlugHash(controller.selectedSocketIndex);
    final canApply = controller.canApplySocket(controller.selectedSocketIndex, controller.selectedPlugHash);

    if (isApplied || !canApply || item?.itemInstanceId == null) {
      return Container();
    }
    final isEnabled = !controller.isSocketBusy(controller.selectedSocketIndex);
    final applyButton = Container(
        padding: const EdgeInsets.only(top: 8),
        child: ElevatedButton(
            key: Key("apply_button_${definition.hash}_$isEnabled"),
            onPressed: isEnabled
                ? () {
                    controller.applySocket(controller.selectedSocketIndex, controller.selectedPlugHash);
                  }
                : null,
            child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
              definition.hash,
              (def) => isEnabled
                  ? TranslatedTextWidget(
                      "Apply {modType}",
                      replace: {"modType": def.itemTypeDisplayName.toLowerCase()},
                    )
                  : DefaultLoadingShimmer(
                      child: TranslatedTextWidget(
                      "Applying {modType}",
                      replace: {"modType": def.itemTypeDisplayName.toLowerCase()},
                    )),
            )));
    if (requirementHash != null && requirementHash != 0) {
      return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(requirementHash, (def) {
        final materials = def?.materials?.where((element) => (element.count ?? 0) > 0);
        if (materials?.isNotEmpty ?? true) {
          return Container();
        }
        return applyButton;
      }, key: Key('apply_button_$requirementHash'));
    }
    return applyButton;
  }
}
