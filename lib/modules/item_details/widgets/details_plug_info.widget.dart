import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/widgets/details_apply_plug_button.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_resource_cost.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_stats.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_wishlist_info.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/integrations/clarity/clarity_plug_info.widget.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/shared/widgets/objectives/objective.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

const _perkIconSize = 40.0;
const _animationDuration = Duration(milliseconds: 300);

class DetailsPlugInfoWidget extends StatelessWidget {
  final DestinyItemSocketCategoryDefinition category;

  const DetailsPlugInfoWidget({
    required this.category,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final selectedPlug = state.selectedPlugForCategory(category);
    if (selectedPlug == null)
      return AnimatedSize(
        duration: _animationDuration,
        child: Container(),
      );
    return AnimatedSize(
      duration: _animationDuration,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
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
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              plugHash,
              noIconPlaceholder: Container(),
              placeholder: DefaultLoadingShimmer(
                  child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(64),
                  color: Colors.white,
                ),
              )),
            ),
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
        buildWishlistInfo(context, plugHash),
        buildEnergyCost(context, plugHash),
        buildSandBoxPerks(context, plugHash),
        buildStats(context),
        buildObjectives(context, plugHash),
        buildCommunityInsights(context, plugHash),
        buildResourceCost(context, plugHash),
        buildWeaponLevelRequired(context, plugHash),
        buildApplyButton(context, plugHash),
        buildUnavailable(context, plugHash),
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
        margin: EdgeInsets.all(8),
        child: Text(
          description,
          style: context.textTheme.body,
        ));
  }

  Widget buildEnergyCost(BuildContext context, int plugHash) {
    final definition = context.definition<DestinyInventoryItemDefinition>(plugHash);
    int value = 0;
    String text = "";
    final cost = definition?.plug?.energyCost?.energyCost;
    final capacity = definition?.plug?.energyCapacity?.capacityValue;
    if (cost != null) {
      value = cost;
      text = "Energy Cost".translate(context).toUpperCase();
    } else if (capacity != null) {
      value = capacity;
      text = "Energy Capacity".translate(context).toUpperCase();
    } else
      return Container();
    return buildInfoContainer(
      context,
      Row(
        children: [
          Container(width: 20, child: Image.asset('assets/imgs/energy-type-icon.png')),
          Container(
            padding: const EdgeInsets.all(4),
            child: Text("$value", style: context.textTheme.itemPrimaryStatHighDensity),
          ),
          Text(
            text,
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

  Widget buildStats(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;

    final selected = state.selectedPlugHashForSocket(socketIndex);
    final equipped = state.equippedPlugHashForSocket(socketIndex);
    final stats = state.selectedPlugStats;
    if (stats == null || stats.isEmpty) return Container();
    return DetailsPlugStatsWidget(
      stats,
      selectedPlugHash: selected,
      equippedPlugHash: equipped,
    );
  }

  buildObjectives(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final objectives = state.getPlugObjectives(plugHash);
    if (objectives == null || objectives.isEmpty) return Container();
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: objectives
            .map((objective) {
              final hash = objective.objectiveHash;
              if (hash == null) return null;
              return ObjectiveWidget(
                hash,
                objective: objective,
              );
            })
            .whereType<Widget>()
            .toList(),
      ),
    );
  }

  Widget buildWishlistInfo(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final tags = state.getWishlistTagsForPlug(plugHash);
    if (tags == null) return Container();
    return DetailsPlugWishlistInfoWidget(tags);
  }

  Widget buildResourceCost(BuildContext context, int plugHash) {
    return DetailsPlugResourceCostWidget(plugHash);
  }

  Widget buildApplyButton(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;
    if (socketIndex == null) return Container();
    return DetailsApplyPlugButtonWidget(socketIndex: socketIndex, plugHash: plugHash);
  }

  Widget buildWeaponLevelRequired(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;
    if (socketIndex == null) return Container();
    final weaponLevelRequired = state.weaponLevelRequired(socketIndex, plugHash);
    if (weaponLevelRequired == null) return Container();
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(children: [
        Container(width: 18, height: 18, child: Image.asset("assets/imgs/deepsight.png")),
        SizedBox(width: 6),
        Text(weaponLevelRequired, style: context.textTheme.caption),
      ]),
    );
  }

  Widget buildUnavailable(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;
    if (socketIndex == null) return Container();
    final canRollOn = state.canRollOn(socketIndex, plugHash);
    final hasEnoughEnergyFor = state.hasEnoughEnergyFor(socketIndex, plugHash);
    if (canRollOn && hasEnoughEnergyFor) return Container();
    return Container(
        margin: EdgeInsets.only(top: 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer1,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(children: [
          if (!canRollOn)
            Row(children: [
              Icon(Icons.warning_amber, color: context.theme.achievementLayers.layer1, size: 20),
              SizedBox(width: 4),
              Text(context.translate("This perk is currently unavailable on this item."),
                  style: context.textTheme.caption),
            ]),
          if (!hasEnoughEnergyFor)
            Row(children: [
              Icon(Icons.warning_amber, color: context.theme.achievementLayers.layer1, size: 20),
              SizedBox(width: 4),
              Text(context.translate("There is not enough energy for this perk."), style: context.textTheme.caption),
            ])
        ]));
  }

  Widget buildCommunityInsights(BuildContext context, int plugHash) {
    return ClarityPlugInfoWidget(plugHash);
  }
}
