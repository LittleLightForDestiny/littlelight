import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/widgets/details_apply_plug_button.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_plug_stats.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';
import 'details_item_cover_plug_wishlistlist_info.widget.dart';

const _perkIconSize = 64.0;
const _animationDuration = Duration(milliseconds: 300);

class DetailsItemCoverPlugInfoWidget extends StatelessWidget {
  final double pixelSize;
  const DetailsItemCoverPlugInfoWidget({
    this.pixelSize = 1,
  }) : super();

  Widget build(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;
    final selectedPlug = state.selectedPlugHashForSocket(socketIndex);
    return AnimatedSize(
      duration: _animationDuration,
      child: AnimatedSwitcher(
        duration: _animationDuration,
        child: SingleChildScrollView(
          key: Key("item cover plug details $selectedPlug"),
          child: buildDetailsBox(context),
        ),
      ),
    );
  }

  Widget buildDetailsBox(BuildContext context) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;
    final selectedPlug = state.selectedPlugHashForSocket(socketIndex);
    if (selectedPlug == null) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16 * pixelSize),
      color: context.theme.surfaceLayers,
      width: 550 * pixelSize,
      alignment: Alignment.topCenter,
      child: Column(children: [
        buildHeader(context, selectedPlug),
        Container(
          padding: EdgeInsets.all(8 * pixelSize),
          child: buildContent(context, selectedPlug),
        ),
      ]),
    );
  }

  Widget buildHeader(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;
    final canFavorite = state.canFavoriteSocket(socketIndex);
    return Container(
      padding: EdgeInsets.all(8 * pixelSize),
      decoration: BoxDecoration(
        color: context.theme.primaryLayers.layer1,
        borderRadius: BorderRadius.circular(4 * pixelSize),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _perkIconSize * pixelSize,
            height: _perkIconSize * pixelSize,
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
          SizedBox(width: 16 * pixelSize),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ManifestText<DestinyInventoryItemDefinition>(
                plugHash,
                style: context.textTheme.title.copyWith(fontSize: 24 * pixelSize),
                uppercase: true,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
              SizedBox(height: 2 * pixelSize),
              ManifestText<DestinyInventoryItemDefinition>(
                plugHash,
                style: context.textTheme.body.copyWith(fontSize: 18 * pixelSize),
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
            width: _perkIconSize * pixelSize,
            height: _perkIconSize * pixelSize,
            child: Icon(
              isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              size: 28 * pixelSize,
            ),
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
        buildApplyButton(context, plugHash),
      ]);

  Widget buildInfoContainer(BuildContext context, Widget child) => Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4 * pixelSize),
      ),
      padding: EdgeInsets.all(8 * pixelSize),
      margin: EdgeInsets.only(top: 8 * pixelSize),
      child: child);

  Widget buildDescription(BuildContext context, int plugHash) {
    final definition = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final description = definition?.displayProperties?.description;
    if (description == null || description.isEmpty) return Container();
    return Container(
        margin: EdgeInsets.all(8 * pixelSize),
        child: Text(
          description,
          style: context.textTheme.body.copyWith(fontSize: 18 * pixelSize),
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
          Container(width: 32 * pixelSize, child: Image.asset('assets/imgs/energy-type-icon.png')),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16 * pixelSize),
            child:
                Text("$value", style: context.textTheme.itemPrimaryStatHighDensity.copyWith(fontSize: 48 * pixelSize)),
          ),
          Text(
            text,
            style: context.textTheme.body.copyWith(fontSize: 24 * pixelSize),
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
      margin: EdgeInsets.all(4 * pixelSize),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: _perkIconSize * pixelSize,
              height: _perkIconSize * pixelSize,
              child: ManifestImageWidget<DestinySandboxPerkDefinition>(perk.perkHash)),
          SizedBox(width: 8 * pixelSize),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ManifestText<DestinySandboxPerkDefinition>(
                perk.perkHash,
                style: context.textTheme.highlight.copyWith(fontSize: 18 * pixelSize),
              ),
              SizedBox(
                height: 2,
              ),
              ManifestText<DestinySandboxPerkDefinition>(
                perk.perkHash,
                style: context.textTheme.body.copyWith(fontSize: 18 * pixelSize),
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
      plugIconSize: 32 * pixelSize,
      comparisonIconSize: 24 * pixelSize,
      fontSize: 18 * pixelSize,
    );
  }

  Widget buildWishlistInfo(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final tags = state.getWishlistTagsForPlug(plugHash);
    if (tags == null) return Container();
    return DetailsItemCoverPlugWishlistInfoWidget(
      tags,
      pixelSize: pixelSize,
    );
  }

  Widget buildApplyButton(BuildContext context, int plugHash) {
    final state = context.watch<SocketControllerBloc>();
    final socketIndex = state.selectedSocketIndex;
    if (socketIndex == null) return Container();
    return DetailsApplyPlugButtonWidget(socketIndex: socketIndex, plugHash: plugHash);
  }
}
