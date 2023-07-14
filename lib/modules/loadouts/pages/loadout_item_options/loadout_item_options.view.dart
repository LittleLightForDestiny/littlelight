import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/widgets/details_item_mods.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_perks.widget.dart';
import 'package:little_light/modules/loadouts/pages/loadout_item_options/loadout_item_options.bottomsheet.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/inventory_item/high_density_inventory_item.dart';
import 'package:little_light/shared/widgets/inventory_item/inventory_item.dart';
import 'loadout_item_options.bloc.dart';

class LoadoutItemOptionsView extends StatelessWidget {
  final LoadoutItemOptionsBloc bloc;
  final LoadoutItemOptionsBloc state;
  final SocketControllerBloc socketState;

  const LoadoutItemOptionsView({
    Key? key,
    required this.bloc,
    required this.state,
    required this.socketState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildItemInfo(context),
                  buildPlugs(context),
                ],
              )),
        ),
        buildOptions(context),
      ],
    );
  }

  Widget buildItemInfo(BuildContext context) {
    final item = state.item.inventoryItem;
    if (item == null) return Container();
    return Container(
      margin: EdgeInsets.all(8).copyWith(top: 0),
      height: InventoryItemWidgetDensity.High.itemHeight,
      child: HighDensityInventoryItem(item),
    );
  }

  Widget buildPlugs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...buildReusablePerks(context),
        ...buildSupers(context),
        ...buildAbilities(context),
        ...buildMods(context),
      ],
    );
  }

  List<Widget> buildReusablePerks(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Reusable) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemPerksWidget(e)).toList();
  }

  List<Widget> buildSupers(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Supers) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemPerksWidget(e)).toList();
  }

  List<Widget> buildAbilities(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Abilities) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemModsWidget(e)).toList();
  }

  List<Widget> buildMods(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Consumable) ?? [];
    final all = reusable;
    return all.map((e) => DetailsItemModsWidget(e)).toList();
  }

  Widget buildOptions(BuildContext context) {
    return Column(
      children: [
        buildOption(
          context,
          text: "Remove item".translate(context),
          icon: FontAwesomeIcons.circleXmark,
          option: LoadoutItemOption.Remove,
        ),
        buildOption(
          context,
          text: "Edit mods".translate(context),
          icon: FontAwesomeIcons.gears,
          option: LoadoutItemOption.EditMods,
        ),
      ],
    );
  }

  Widget buildOption(
    BuildContext context, {
    required String text,
    required IconData icon,
    required LoadoutItemOption option,
  }) {
    return Container(
      margin: EdgeInsets.all(8).copyWith(top: 0),
      child: Stack(children: [
        Container(
          height: kToolbarHeight,
          child: Row(children: [
            AspectRatio(aspectRatio: 1, child: Icon(icon)),
            Expanded(
              child: Text(
                text,
                style: context.textTheme.button,
              ),
            )
          ]),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => bloc.selectOption(option),
            ),
          ),
        ),
      ]),
    );
  }
}
