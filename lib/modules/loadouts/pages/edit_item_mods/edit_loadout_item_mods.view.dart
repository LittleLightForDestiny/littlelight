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
  EditLoadoutItemModsBloc _bloc(BuildContext context) => context.read<EditLoadoutItemModsBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        IconButton(
            onPressed: () {
              _bloc(context).computeAvailableCategories();
            },
            icon: Icon(Icons.refresh)),
        buildList(context),
      ],
    ));
  }

  Widget buildList(BuildContext context) {
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
        return buildCategoryContents(context, category);
    }
  }

  Widget buildCategoryContents(BuildContext context, DestinyItemSocketCategoryDefinition category) {
    final indexes = _bloc(context).availableIndexesForCategory(category);
    if (indexes == null) return Container();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: indexes.map((index) => buildSocket(context, index)).toList());
  }

  Widget buildSocket(BuildContext context, int socketIndex) {
    final equipped = _state(context).equippedPlugHashForSocket(socketIndex);
    final available = _state(context).availablePlugHashesForSocket(socketIndex);
    if (available == null && equipped == null) return Container();
    return Column(children: [
      if (equipped != null) buildEquippedPlug(context, socketIndex, equipped),
      if (available != null) buildAvailablePlugs(context, socketIndex, available)
    ]);
  }

  Widget buildEquippedPlug(BuildContext context, int socketIndex, int plugHash) {
    final canApply = _state(context).canApplyForFree(socketIndex, plugHash);
    return Row(
      children: [
        Container(
          color: canApply ? Colors.transparent : Colors.red,
          width: 64,
          height: 64,
          child:
              Opacity(opacity: canApply ? 1 : .5, child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash)),
        ),
        Container(
          width: 16,
        ),
        ManifestText<DestinyInventoryItemDefinition>(plugHash)
      ],
    );
  }

  Widget buildAvailablePlugs(BuildContext context, int socketIndex, List<int> plugs) {
    return Wrap(
      children: plugs.map(
        (p) {
          final canApply = _state(context).canApplyForFree(socketIndex, p);
          return Container(
            width: 64,
            height: 64,
            color: canApply ? Colors.transparent : Colors.red,
            child: Opacity(opacity: canApply ? 1 : .5, child: ManifestImageWidget<DestinyInventoryItemDefinition>(p)),
          );
        },
      ).toList(),
    );
  }
}
