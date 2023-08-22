import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

import 'equip_random_loadout.bloc.dart';

typedef _SetBoolCallback = void Function(bool);

class LoadoutItemOptionsView extends StatelessWidget {
  final EquipRandomLoadoutBloc bloc;
  final EquipRandomLoadoutBloc state;

  const LoadoutItemOptionsView({
    Key? key,
    required this.bloc,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showItems = state.showItems;
    return Container(
      constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * .8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          if (showItems) Flexible(child: SingleChildScrollView(child: buildLoadout(context))),
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
          "Random Loadout".translate(context).toUpperCase(),
        ),
      ),
    );
  }

  Widget buildLoadout(BuildContext context) {
    return Column(
      children: state.loadout?.values
              .map((e) => e != null
                  ? Container(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      child: HighDensityInventoryItem(e),
                      height: InventoryItemWidgetDensity.High.itemHeight,
                    )
                  : Container())
              .toList() ??
          [],
    );
  }

  Widget buildOptions(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: context.mediaQuery.padding.bottom, top: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          buildRollButton(context),
          buildItemsToInclude(context),
        ]));
  }

  Widget buildRollButton(BuildContext context) {
    return MenuBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            buildItemTypeSwitch(
              context,
              Text("Show items".translate(context)),
              state.showItems,
              (value) => bloc.showItems = value,
            )
          ]),
          Container(height: 4),
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () => bloc.roll(),
                    child: Text(
                      "Randomize".translate(context),
                      softWrap: false,
                    ))),
            Container(
              width: 4,
            ),
            Expanded(
                child: ElevatedButton(
                    onPressed: () => bloc.select(),
                    child: Text(
                      "Select".translate(context),
                      softWrap: false,
                    ))),
            Container(
              width: 4,
            ),
            Expanded(
                child: ElevatedButton(
                    onPressed: () => bloc.equip(),
                    child: Text(
                      "Equip".translate(context),
                      softWrap: false,
                    ))),
          ]),
        ],
      ),
    );
  }

  Widget buildItemsToInclude(BuildContext context) {
    final types = [
      buildItemTypeSwitch(
        context,
        ManifestText<DestinyItemCategoryDefinition>(DestinyItemCategory.Weapon),
        state.equipWeapons,
        (value) => bloc.equipWeapons = value,
      ),
      buildItemTypeSwitch(
        context,
        ManifestText<DestinyItemCategoryDefinition>(DestinyItemCategory.Armor),
        state.equipArmor,
        (value) => bloc.equipArmor = value,
      ),
      buildItemTypeSwitch(
        context,
        ManifestText<DestinyInventoryBucketDefinition>(InventoryBucket.subclass),
        state.equipSubclass,
        (value) => bloc.equipSubclass = value,
      ),
      buildItemTypeSwitch(
        context,
        Text("Force exotics".translate(context)),
        state.forceExotics,
        (value) => bloc.forceExotics = value,
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

  Widget buildItemTypeSwitch(BuildContext context, Widget label, bool value, _SetBoolCallback setValue) {
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
              LLSwitch.callback(value, setValue)
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ),
        style: context.textTheme.highlight,
      ),
    );
  }
}
