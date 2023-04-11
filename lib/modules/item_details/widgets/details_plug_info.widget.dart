import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/socket_controller.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

const _perkIconSize = 40.0;

class DetailsPlugInfoWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition category;

  const DetailsPlugInfoWidget({
    required this.category,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final selectedPlug = state.selectedPlugForCategory(category);
    if (selectedPlug == null) return Container();
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildHeader(context, selectedPlug),
          buildContent(context, selectedPlug),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final canFavorite = state.canFavorite(category);
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.primaryLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _perkIconSize,
            height: _perkIconSize,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash),
          ),
          SizedBox(width: 8),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ManifestText<DestinyInventoryItemDefinition>(
                plugHash,
                style: context.textTheme.title,
                uppercase: true,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
              SizedBox(height: 2),
              ManifestText<DestinyInventoryItemDefinition>(
                plugHash,
                style: context.textTheme.body,
                uppercase: true,
                textExtractor: (def) => def.itemTypeDisplayName,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
            ],
          )),
          if (canFavorite) buildFavoriteButton(context, plugHash)
        ],
      ),
    );
  }

  Widget buildFavoriteButton(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final isFavorite = state.isFavoritePlug(plugHash);
    return Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: CircleBorder(),
          onTap: () {
            context.read<SocketControllerBloc>().setFavoritePlug(plugHash, !isFavorite);
          },
          child: Container(
            width: _perkIconSize,
            height: _perkIconSize,
            child: Icon(isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart),
          ),
        ));
  }

  Widget buildContent(BuildContext context, int plugHash) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        buildDescription(context, plugHash),
        buildEnergyCost(context, plugHash),
        buildSandBoxPerks(context, plugHash),
        //TODO: finish plug details applications
        // buildStats(context),
        // buildObjectives(context),
        // buildWishlistInfo(context),
        // buildApplyButton(context)
      ]);

  Widget buildInfoContainer(BuildContext context, Widget child) => Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.only(top: 4),
      child: child);

  Widget buildDescription(BuildContext context, int plugHash) {
    final definition = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final description = definition?.displayProperties?.description;
    if (description == null || description.isEmpty) return Container();
    return Container(
        margin: EdgeInsets.only(top: 4),
        child: Text(
          description,
          style: context.textTheme.body,
        ));
  }

  Widget buildEnergyCost(BuildContext context, int plugHash) {
    final definition = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final cost = definition?.plug?.energyCost?.energyCost;
    if (cost == null) return Container();
    return buildInfoContainer(
      context,
      Row(
        children: [
          Container(width: 20, child: Image.asset('assets/imgs/energy-type-icon.png')),
          Container(
            padding: const EdgeInsets.all(4),
            child: Text("$cost", style: context.textTheme.itemPrimaryStatHighDensity),
          ),
          Text(
            "Energy Cost".translate(context).toUpperCase(),
            style: context.textTheme.body,
          ),
        ],
      ),
    );
  }

  Widget buildSandBoxPerks(BuildContext context, int plugHash) {
    final definition = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final perks =
        definition?.perks?.map((perk) => buildSandBoxPerk(context, plugHash, perk)).whereType<Widget>().toList();
    if (perks == null) return Container();
    if (perks.isEmpty) return Container();
    return buildInfoContainer(
      context,
      Column(
        children: perks,
      ),
    );
  }

  Widget? buildSandBoxPerk(BuildContext context, int plugHash, DestinyItemPerkEntryDefinition perk) {
    final isVisible = perk.perkVisibility == ItemPerkVisibility.Visible;
    if (!isVisible) return null;
    final perkDef = context.definition<DestinySandboxPerkDefinition>(perk.perkHash);
    final isDisplayable = perkDef?.isDisplayable ?? false;
    if (!isDisplayable) return null;
    final plugDef = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final hasIdenticalDescription = plugDef?.displayProperties?.description == perkDef?.displayProperties?.description;
    if (hasIdenticalDescription) return null;
    return Container(
      margin: EdgeInsets.all(2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: _perkIconSize,
              height: _perkIconSize,
              child: ManifestImageWidget<DestinySandboxPerkDefinition>(perk.perkHash)),
          SizedBox(width: 4),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ManifestText<DestinySandboxPerkDefinition>(
                perk.perkHash,
                style: context.textTheme.highlight,
              ),
              SizedBox(
                height: 2,
              ),
              ManifestText<DestinySandboxPerkDefinition>(
                perk.perkHash,
                style: context.textTheme.body,
                textExtractor: (def) => def.displayProperties?.description,
              ),
            ],
          )),
        ],
      ),
    );
  }

  buildStats(BuildContext context, int plugHash) {
    final def = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final stats = def?.investmentStats?.where((e) {
      final isConditionallyActive = e.isConditionallyActive ?? false;

      return !isConditionallyActive;
    });
    return Column(children: [
      // ItemDetailSocketItemStatsWidget(
      //   plugDefinition: definition,
      //   definition: itemDefinition,
      //   item: item,
      //   socketController: widget.controller,
      // )
    ]);
  }

  buildObjectives(BuildContext context) {
    return Container();
    // var itemObjectives = profile.getPlugObjectives(item?.itemInstanceId);
    // if (!(itemObjectives?.containsKey("${definition.hash}") ?? false)) return Container();
    // var objectives = itemObjectives["${definition.hash}"];
    // return Column(
    //     children: <Widget>[
    //   Divider(
    //     thickness: 1,
    //     color: Theme.of(context).colorScheme.onSurface,
    //   )
    // ]
    //         .followedBy(objectives.map((o) => ObjectiveWidget(
    //               objective: o,
    //             )))
    //         .toList());
  }

  Widget buildReusableMods(BuildContext context) {
    return Container();
    // final plugs = controller.socketPlugHashes(controller.selectedSocketIndex);

    // return Container(
    //     padding: const EdgeInsets.only(bottom: 8),
    //     child: LayoutBuilder(builder: (context, constraints) {
    //       final width = constraints.maxWidth - 32;
    //       final itemsPerRow = (width / 48).floor();
    //       final rowCount = (plugs.length / itemsPerRow).ceil().clamp(0, 3);
    //       final tabCount = (plugs.length / (itemsPerRow * rowCount)).ceil();
    //       final itemHeight = width / itemsPerRow;
    //       final gridHeight = itemHeight * rowCount - 8;

    //       return DefaultTabController(
    //           length: tabCount,
    //           child: SizedBox(
    //             height: gridHeight,
    //             child: Row(children: [
    //               Builder(builder: (context) => pagingButton(context, -1)),
    //               Expanded(
    //                   child: PlugGridView.withItemsPerRow(
    //                 plugs,
    //                 itemBuilder: (h) => buildMod(context, controller.selectedSocketIndex, h),
    //                 itemsPerRow: itemsPerRow,
    //                 maxRows: rowCount,
    //                 gridSpacing: 8,
    //               )),
    //               Builder(builder: (context) => pagingButton(context, 1)),
    //             ]),
    //           ));
    //     }));
  }

  Widget pagingButton(BuildContext context, [int direction = 1]) {
    return Container();
    // final controller = DefaultTabController.of(context);
    // final length = controller.length;

    // return AnimatedBuilder(
    //     animation: controller.animation,
    //     builder: (context, child) {
    //       final currentIndex = controller.index;
    //       final enabled = direction < 0 ? currentIndex > 0 : currentIndex < length - 1;
    //       return Container(
    //         constraints: const BoxConstraints.expand(width: 16),
    //         decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
    //         padding: const EdgeInsets.all(0),
    //         alignment: Alignment.center,
    //         child: !enabled
    //             ? Container(color: Colors.grey.shade300.withOpacity(.2))
    //             : Material(
    //                 color: Colors.transparent,
    //                 child: InkWell(
    //                     onTap: () {
    //                       controller.animateTo(currentIndex + direction);
    //                     },
    //                     child: Container(
    //                         constraints: const BoxConstraints.expand(),
    //                         child: Icon(direction > 0 ? FontAwesomeIcons.caretRight : FontAwesomeIcons.caretLeft,
    //                             size: 16)))),
    //       );
    //     });
  }

  Widget buildMod(BuildContext context, int socketIndex, int plugItemHash) {
    return Container();
    // bool isFavorite = itemNotes.getNotesForItem(plugItemHash, null)?.tags?.contains("favorite") ?? false;
    // bool isSelected = plugItemHash == controller.selectedPlugHash;
    // Color borderColor =
    //     isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(.5);

    // BorderSide borderSide = BorderSide(color: borderColor, width: isSelected ? 3 : 1);
    // var def = controller.plugDefinitions[plugItemHash];
    // var energyType = def?.plug?.energyCost?.energyType ?? DestinyEnergyType.Any;
    // var energyCost = def?.plug?.energyCost?.energyCost ?? 0;
    // var canEquip = controller?.canEquip(socketIndex, plugItemHash);
    // var screenWidth = MediaQuery.of(context).size.width - 16;

    // return Container(
    //     width: min(64, screenWidth / 8),
    //     key: Key("plug_${socketIndex}_$plugItemHash"),
    //     padding: const EdgeInsets.all(0),
    //     child: AspectRatio(
    //         aspectRatio: 1,
    //         child: MaterialButton(
    //           shape: ContinuousRectangleBorder(side: borderSide),
    //           padding: const EdgeInsets.all(0),
    //           child: Stack(children: [
    //             ManifestImageWidget<DestinyInventoryItemDefinition>(plugItemHash),
    //             energyType == DestinyEnergyType.Any
    //                 ? Container()
    //                 : Positioned.fill(
    //                     child:
    //                         ManifestImageWidget<DestinyStatDefinition>(DestinyData.getEnergyTypeCostHash(energyType))),
    //             energyCost == 0
    //                 ? Container()
    //                 : Positioned(
    //                     top: 4,
    //                     right: 4,
    //                     child: Text(
    //                       "$energyCost",
    //                       style: const TextStyle(fontSize: 12),
    //                     )),
    //             canEquip
    //                 ? Container()
    //                 : Positioned.fill(
    //                     child: Container(
    //                       color: Colors.black.withOpacity(.5),
    //                     ),
    //                   ),
    //             if (isFavorite) const Positioned(right: 2, top: 2, child: Icon(FontAwesomeIcons.solidHeart, size: 10))
    //           ]),
    //           onPressed: () {
    //             controller.selectSocket(socketIndex, plugItemHash);
    //           },
    //         )));
  }

  Widget buildRandomPerks(BuildContext context) {
    return Container();
    // final plugs = controller.possiblePlugHashes(controller.selectedSocketIndex);
    // if (plugs?.isEmpty ?? false) {
    //   return Container();
    // }
    // var screenWidth = MediaQuery.of(context).size.width - 16;
    // var dividerMargin = min(screenWidth / 50, 8.0);
    // return Container(
    //     padding: const EdgeInsets.only(bottom: 8),
    //     child: Wrap(
    //       runSpacing: dividerMargin,
    //       spacing: dividerMargin,
    //       children: plugs.map((p) => buildPerk(context, controller.selectedSocketIndex, p)).toList(),
    //     ));
  }

  Widget buildResourceCost(BuildContext context) {
    // var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    // if (requirementHash != null) {
    //   return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(requirementHash, (def) {
    //     final materials = def?.materials?.where((element) => (element.count ?? 0) > 0);
    //     if (materials?.isEmpty ?? true) {
    //       return Container();
    //     }
    //     return Container(
    //         decoration: BoxDecoration(
    //           color: Colors.black,
    //           border: Border(top: BorderSide(color: Colors.grey.shade500, width: 1)),
    //         ),
    //         padding: const EdgeInsets.all(8),
    //         child: Column(
    //           children: materials.map((m) {
    //             return Row(
    //               children: <Widget>[
    //                 SizedBox(
    //                     width: 20, height: 20, child: ManifestImageWidget<DestinyInventoryItemDefinition>(m.itemHash)),
    //                 Expanded(
    //                   child: Container(
    //                     padding: const EdgeInsets.only(left: 8),
    //                     child: ManifestText<DestinyInventoryItemDefinition>(
    //                       m.itemHash,
    //                       style: const TextStyle(fontWeight: FontWeight.w300),
    //                     ),
    //                   ),
    //                 ),
    //                 Text("${m.count}", style: const TextStyle(fontWeight: FontWeight.w300))
    //               ],
    //             );
    //           }).toList(),
    //         ));
    //   }, key: Key("material_requirements_$requirementHash"));
    // }
    return Container();
  }

  Widget buildPerk(BuildContext context, int socketIndex, int plugItemHash) {
    return Container();
    // var plugDef = controller.plugDefinitions[plugItemHash];
    // int equippedHash = controller.socketEquippedPlugHash(socketIndex);
    // bool isEquipped = equippedHash == plugItemHash;
    // bool isSelectedOnSocket = plugItemHash == controller.socketSelectedPlugHash(socketIndex);
    // bool isSelected = plugItemHash == controller.selectedPlugHash;
    // bool canRoll = controller.item != null || controller.canRollPerk(socketIndex, plugItemHash);
    // var screenWidth = MediaQuery.of(context).size.width;
    // return SizedBox(
    //     width: min(64, screenWidth / 8),
    //     child: SelectablePerkWidget(
    //       selected: isSelected,
    //       selectedOnSocket: isSelectedOnSocket,
    //       itemDefinition: widget.definition,
    //       plugHash: plugItemHash,
    //       plugDefinition: plugDef,
    //       equipped: isEquipped,
    //       canRoll: canRoll,
    //       key: Key("$plugItemHash $isSelected $isSelectedOnSocket"),
    //       onTap: () {
    //         controller.selectSocket(socketIndex, plugItemHash);
    //       },
    //     ));
  }

  Widget buildApplyButton(BuildContext context) {
    return Container();
    // var requirementHash = definition?.plug?.insertionMaterialRequirementHash;
    // final isApplied = controller.selectedPlugHash == controller.socketEquippedPlugHash(controller.selectedSocketIndex);
    // final canApply = controller.canApplySocket(controller.selectedSocketIndex, controller.selectedPlugHash);

    // if (isApplied || !canApply || item?.itemInstanceId == null) {
    //   return Container();
    // }
    // final isEnabled = !controller.isSocketBusy(controller.selectedSocketIndex);
    // final applyButton = Container(
    //     padding: const EdgeInsets.only(top: 8),
    //     child: ElevatedButton(
    //         key: Key("apply_button_${definition.hash}_$isEnabled"),
    //         onPressed: isEnabled
    //             ? () {
    //                 controller.applySocket(controller.selectedSocketIndex, controller.selectedPlugHash);
    //               }
    //             : null,
    //         child: DefinitionProviderWidget<DestinyInventoryItemDefinition>(
    //           definition.hash,
    //           (def) => isEnabled
    //               ? TranslatedTextWidget(
    //                   "Apply {modType}",
    //                   replace: {"modType": def.itemTypeDisplayName.toLowerCase()},
    //                 )
    //               : DefaultLoadingShimmer(
    //                   child: TranslatedTextWidget(
    //                   "Applying {modType}",
    //                   replace: {"modType": def.itemTypeDisplayName.toLowerCase()},
    //                 )),
    //         )));
    // if (requirementHash != null && requirementHash != 0) {
    //   return DefinitionProviderWidget<DestinyMaterialRequirementSetDefinition>(requirementHash, (def) {
    //     final materials = def?.materials?.where((element) => (element.count ?? 0) > 0);
    //     if (materials?.isNotEmpty ?? true) {
    //       return Container();
    //     }
    //     return applyButton;
    //   }, key: Key('apply_button_$requirementHash'));
    // }
    // return applyButton;
  }
}
