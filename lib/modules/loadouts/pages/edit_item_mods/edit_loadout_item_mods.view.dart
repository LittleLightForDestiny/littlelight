import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/pages/edit_item_mods/edit_loadout_item_mods.bloc.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/item_sockets/mod_grid_item.dart';
import 'package:little_light/widgets/item_sockets/paginated_plug_grid_view.dart';
import 'package:provider/provider.dart';

const emptyLoadoutModHash = 1219897208;

class EditLoadoutItemModsView extends StatelessWidget {
  EditLoadoutItemModsBloc _bloc(BuildContext context) => context.read<EditLoadoutItemModsBloc>();
  EditLoadoutItemModsBloc _state(BuildContext context) => context.watch<EditLoadoutItemModsBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
      bottomNavigationBar: buildFooter(context),
    );
  }

  PreferredSizeWidget buildAppBar(BuildContext context) => AppBar(
        title: Text("Edit Mods".translate(context)),
        flexibleSpace: buildAppBarBackground(context),
      );

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
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
      Container(
        padding: EdgeInsets.all(8),
        child: HeaderWidget(
          child: ManifestText<DestinySocketCategoryDefinition>(categoryHash),
        ),
      ),
      DefinitionProviderWidget<DestinySocketCategoryDefinition>(
        categoryHash,
        (def) => buildCategoryOptions(
          context,
          category,
          def,
        ),
      )
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
    bool isCategorySelected = _state(context).isCategorySelected(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildCategorySockets(context, category),
        AnimatedSize(
          alignment: Alignment.topLeft,
          duration: Duration(milliseconds: 300),
          child: isCategorySelected ? buildSocketPlugs(context, category) : Container(),
        ),
      ],
    );
  }

  Widget buildCategorySockets(BuildContext context, DestinyItemSocketCategoryDefinition category) {
    final indexes = _state(context).availableIndexesForCategory(category);
    if (indexes == null) return Container();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: indexes.map((index) => buildSocket(context, index)).toList(),
        ),
      ),
    );
  }

  Widget buildSocket(BuildContext context, int socketIndex) {
    final isSelected = _state(context).isSocketSelected(socketIndex);
    final theme = LittleLightTheme.of(context);
    return Material(
      color: isSelected ? theme.surfaceLayers.layer1 : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (isSelected) {
            _bloc(context).unselectSockets();
          } else {
            _bloc(context).selectSocket(socketIndex);
          }
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: buildSocketIcon(context, socketIndex),
        ),
      ),
    );
  }

  Widget buildSocketIcon(BuildContext context, socketIndex) {
    final plugHash = _state(context).selectedSelectedPlugHash(socketIndex);
    if (plugHash == null) return buildEmptySlot(context, socketIndex);
    return Container(
      width: 64,
      height: 64,
      child: ModGridItem(plugHash),
    );
  }

  Widget buildEmptySlot(BuildContext context, int socketIndex) {
    final equippedPlugHash = _state(context).socketEquippedPlugHash(socketIndex);
    return Container(
      width: 64,
      height: 64,
      child: Stack(children: [
        Positioned.fill(
          child: ModGridItem(emptyLoadoutModHash),
        ),
        if (equippedPlugHash != null)
          Positioned(
            height: 24,
            width: 24,
            bottom: 4,
            right: 4,
            child: ModGridItem(equippedPlugHash),
          )
      ]),
    );
  }

  Widget buildSocketPlugs(BuildContext context, DestinyItemSocketCategoryDefinition category) {
    final plugs = _state(context).selectedSocketPlugs();
    final socketIndex = _state(context).selectedSocket;

    if (plugs == null) return Container();
    if (plugs.length == 0) return Container();
    if (socketIndex == null) return Container();

    final selectedSocketDefaultPlug = _state(context).selectedSocketDefaultPlugHash;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        color: LittleLightTheme.of(context).surfaceLayers.layer1,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(children: [
          if (selectedSocketDefaultPlug != null)
            HeaderWidget(
              child: ManifestText<DestinyInventoryItemDefinition>(
                selectedSocketDefaultPlug,
                textExtractor: (def) {
                  return "${def.itemTypeDisplayName}";
                },
                key: Key("plug_type_$selectedSocketDefaultPlug"),
              ),
            ),
          Container(
            height: 8,
          ),
          PaginatedPlugGridView.withExpectedItemSize(
            plugs,
            itemBuilder: (plugHash) {
              final isSelected = _state(context).isPlugSelectedForSocket(plugHash, socketIndex);
              final isEquipped = _state(context).isPlugEquippedForSocket(plugHash, socketIndex);
              if (plugHash == null) {
                return ModGridItem(emptyLoadoutModHash, canEquip: true, selected: isSelected, equipped: isEquipped,
                    onTap: () {
                  if (isSelected) {
                    _bloc(context).unselectSockets();
                  } else {
                    _bloc(context).removePlugHashForSocket(socketIndex);
                  }
                });
              }
              return ModGridItem(
                plugHash,
                canEquip: true,
                selected: isSelected,
                equipped: isEquipped,
                onTap: () {
                  if (isSelected) {
                    _bloc(context).unselectSockets();
                  } else {
                    _bloc(context).selectPlugHashForSocket(plugHash, socketIndex);
                  }
                },
              );
            },
            expectedItemSize: 72,
            gridSpacing: 4,
          ),
        ]),
      ),
    );
  }

  Widget buildFooter(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    if (!_state(context).hasChanges) return Container(height: paddingBottom);
    return Material(
        elevation: 1,
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: buildAppBarBackground(context)),
            Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 8 + paddingBottom),
              child: ElevatedButton(
                  child: Text("Update Mods".translate(context)),
                  onPressed: () {
                    _bloc(context).updateMods();
                  }),
            )
          ],
        ));
  }

  Widget buildAppBarBackground(BuildContext context) {
    final emblemHash = _state(context).emblemHash;
    if (emblemHash == null) return Container();
    return Container(
      constraints: BoxConstraints.expand(),
      child: ManifestImageWidget<DestinyInventoryItemDefinition>(
        emblemHash,
        fit: BoxFit.cover,
        alignment: Alignment(-.8, 0),
        urlExtractor: (def) => def.secondarySpecial,
      ),
    );
  }
}
