import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_list_item.widget.dart';
import 'package:little_light/modules/loadouts/widgets/loadout_small_list_item.widget.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/blocs/scoped_value_repository/page_storage_helper.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

import 'equip_loadout_quickmenu.bloc.dart';

class EquipLoadoutQuickmenuView extends StatelessWidget {
  final EquipLoadoutQuickmenuBloc bloc;
  final EquipLoadoutQuickmenuBloc state;

  const EquipLoadoutQuickmenuView({
    Key? key,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * .8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [buildLoadoutList(context)],
                )),
          ),
          buildOptions(context),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: HeaderWidget(
        child: Text(
          (state.equip ? "Equip Loadout".translate(context) : "Transfer Loadout".translate(context)).toUpperCase(),
        ),
      ),
    );
  }

  Widget buildOptions(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: context.mediaQuery.padding.bottom, top: 8),
        child: context.mediaQuery.tabletOrBigger
            ? IntrinsicHeight(
                child: Row(children: [
                Expanded(child: buildFreeSlotsSlider(context)),
                SizedBox(width: 8),
                Expanded(child: buildItemsToInclude(context))
              ]))
            : Column(children: [
                buildFreeSlotsSlider(context),
                buildItemsToInclude(context),
              ]));
  }

  Widget buildFreeSlotsSlider(BuildContext context) {
    return MenuBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.all(2),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.theme.surfaceLayers.layer1,
            ),
            child: Row(children: [
              Expanded(
                  child: Text(
                "Free Slots".translate(context),
                style: context.textTheme.highlight,
              )),
              Text(
                "${state.freeSlots}",
                style: context.textTheme.highlight,
              )
            ]),
          ),
          Slider(
            min: 0,
            max: 9,
            value: state.freeSlots.toDouble(),
            onChanged: (value) => state.freeSlots = value.floor(),
          ),
        ],
      ),
    );
  }

  Widget buildItemsToInclude(BuildContext context) {
    final types = [
      buildItemTypeSwitch(
        context,
        ManifestText<DestinyItemCategoryDefinition>(DestinyItemCategory.Weapon),
        LoadoutIncludedItemTypes.Weapon,
      ),
      buildItemTypeSwitch(
        context,
        ManifestText<DestinyItemCategoryDefinition>(DestinyItemCategory.Armor),
        LoadoutIncludedItemTypes.Armor,
      ),
      buildItemTypeSwitch(
        context,
        ManifestText<DestinyInventoryBucketDefinition>(InventoryBucket.subclass),
        LoadoutIncludedItemTypes.Subclass,
      ),
      buildItemTypeSwitch(
        context,
        Text("Other".translate(context)),
        LoadoutIncludedItemTypes.Other,
      ),
    ];
    return MenuBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [types[0], types[1]]),
          Row(children: [types[2], types[3]]),
        ],
      ),
    );
  }

  Widget buildItemTypeSwitch(BuildContext context, Widget label, LoadoutIncludedItemTypes key) {
    return Expanded(
      child: DefaultTextStyle(
        child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: context.theme.surfaceLayers.layer1,
          ),
          child: Row(
            children: [
              Expanded(child: label),
              SizedBox(
                width: 4,
              ),
              LLSwitch.callback(context.readValue(IncludedItemTypes(key))?.value ?? false, (value) {
                context.storeValue(IncludedItemTypes(key, value));
              })
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ),
        style: context.textTheme.highlight,
      ),
    );
  }

  Widget buildLoadoutList(BuildContext context) {
    final loadouts = state.loadouts;
    final destinyLoadouts = state.destinyLoadouts ?? <DestinyLoadoutInfo>[];
    if (loadouts == null) return Container(height: 256, child: LoadingAnimWidget());
    return Column(children: [
      ...loadouts
          .map((e) => LoadoutSmallListItemWidget(
                e,
                classFilter: state.character.character.classType,
                bucketFilter: state.selectedBuckets,
                onTap: () => bloc.loadoutSelected(e),
              ))
          .toList(),
      ...destinyLoadouts.map((loadout) => Container(
            padding: EdgeInsets.all(4),
            child: DestinyLoadoutListItemWidget(
              loadout,
              onTap: () => bloc.destinyLoadoutSelected(loadout),
            ),
          ))
    ]);
  }
}
