import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.bloc.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

class EditLoadoutItemModsView extends StatelessWidget {
  EditLoadoutItemModsBloc _state(BuildContext context) => context.watch<EditLoadoutItemModsBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final categories = _state(context).categories;
    if (categories == null) return Container();
    return Column(
      children: categories //
          .map((category) => buildCategory(context, category))
          .toList(),
    );
  }

  Widget buildCategory(BuildContext context, DestinyItemSocketCategoryDefinition category) {
    final categoryHash = category.socketCategoryHash;
    if (categoryHash == null) return Container();
    return Column(children: <Widget>[
      HeaderWidget(child: ManifestText<DestinySocketCategoryDefinition>(categoryHash)),
      DefinitionProviderWidget<DestinySocketCategoryDefinition>(
          categoryHash, (def) => buildCategoryOptions(context, category, def))
    ]);
  }

  Widget buildCategoryOptions(
    BuildContext context,
    DestinyItemSocketCategoryDefinition category,
    DestinySocketCategoryDefinition def,
  ) {
    switch (def.categoryStyle) {
      case DestinySocketCategoryStyle.Unknown:
      case DestinySocketCategoryStyle.Reusable:
      case DestinySocketCategoryStyle.Consumable:
      case DestinySocketCategoryStyle.Unlockable:
      case DestinySocketCategoryStyle.Intrinsic:
      case DestinySocketCategoryStyle.EnergyMeter:
      case DestinySocketCategoryStyle.LargePerk:
      case DestinySocketCategoryStyle.Abilities:
      case DestinySocketCategoryStyle.Supers:
      case DestinySocketCategoryStyle.ProtectedInvalidEnumValue:
      case null:
        return buildPerks(context, category);
    }
  }

  Widget buildPerks(BuildContext context, DestinyItemSocketCategoryDefinition category) {
    final indexes = category.socketIndexes;
    if (indexes == null) return Container();
    return Row(children: indexes.map((index) => buildPerkSlot(context, index)).toList());
  }

  Widget buildPerkSlot(BuildContext context, int socketIndex) {
    final perks = _state(context).availablePlugHashesForSocket(socketIndex);
    if (perks == null) return Container();
    return Column(
      children: perks
          .map((hash) => Container(
                width: 64,
                height: 64,
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(hash),
              ))
          .toList(),
    );
  }
}
