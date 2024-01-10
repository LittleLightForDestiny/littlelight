import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/modules/loadouts/pages/destiny_loadout_details/destiny_loadout_details.bloc.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_item.widget.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class DestinyLoadoutDetailsView extends StatelessWidget {
  final DestinyLoadoutDetailsBloc bloc;
  final DestinyLoadoutDetailsBloc state;
  const DestinyLoadoutDetailsView({
    super.key,
    required this.bloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = context.mediaQuery.viewPadding;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: context.theme.surfaceLayers.layer1,
            padding: EdgeInsets.only(top: viewPadding.top + kToolbarHeight),
            child: SingleChildScrollView(
              child: buildItems(context),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: buildAppBar(context),
          ),
        ],
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    final viewPadding = context.mediaQuery.viewPadding;
    final barBackgroundHeight = viewPadding.top + kToolbarHeight;
    final totalHeight = viewPadding.top + kTextTabBarHeight * 1.4;
    return Container(
        height: totalHeight,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: barBackgroundHeight,
              child: Container(
                height: barBackgroundHeight,
                child: ManifestImageWidget<DestinyLoadoutColorDefinition>(
                  state.loadout?.loadout.colorHash,
                  urlExtractor: (def) => def.colorImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
                top: viewPadding.top,
                left: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: kToolbarHeight,
                      height: kToolbarHeight,
                      alignment: Alignment.center,
                      child: BackButton(),
                    ),
                    Transform.translate(
                      offset: Offset(-kToolbarHeight * .5, 0),
                      child: Container(
                        width: kToolbarHeight * 1.4,
                        height: kToolbarHeight * 1.4,
                        child: ManifestImageWidget<DestinyLoadoutIconDefinition>(
                          state.loadout?.loadout.iconHash,
                          urlExtractor: (def) => def.iconImagePath,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-kToolbarHeight * .6, 0),
                      child: Container(
                        height: kToolbarHeight * 1.2,
                        alignment: Alignment.center,
                        child: ManifestText<DestinyLoadoutNameDefinition>(
                          state.loadout?.loadout.nameHash,
                          textExtractor: (def) => def.name?.toUpperCase(),
                          style: context.textTheme.itemNameHighDensity.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ));
  }

  Widget buildItems(BuildContext context) {
    final items = state.loadout?.items;
    if (items == null || items.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildLoadoutItem(context, items[InventoryBucket.subclass]),
        buildLoadoutItem(context, items[InventoryBucket.kineticWeapons]),
        buildLoadoutItem(context, items[InventoryBucket.energyWeapons]),
        buildLoadoutItem(context, items[InventoryBucket.powerWeapons]),
        buildLoadoutItem(context, items[InventoryBucket.helmet]),
        buildLoadoutItem(context, items[InventoryBucket.gauntlets]),
        buildLoadoutItem(context, items[InventoryBucket.chestArmor]),
        buildLoadoutItem(context, items[InventoryBucket.legArmor]),
        buildLoadoutItem(context, items[InventoryBucket.classArmor]),
      ],
    );
  }

  Widget buildLoadoutItem(BuildContext context, DestinyLoadoutItemInfo? item) {
    if (item == null) return Container();
    return DestinyLoadoutItemWidget(item);
  }
}
