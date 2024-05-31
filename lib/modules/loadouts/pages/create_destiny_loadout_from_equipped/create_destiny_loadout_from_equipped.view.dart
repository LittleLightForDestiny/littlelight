import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/destiny_loadout.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_item.widget.dart';
import 'package:little_light/modules/loadouts/widgets/loadouts_character_header.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';
import 'package:little_light/shared/widgets/scrollable_grid_view/paginated_plug_grid_view.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

import 'create_destiny_loadout_from_equipped.bloc.dart';

const _notFoundIconHash = 29505215;

class CreateDestinyLoadoutFromEquippedView extends StatelessWidget {
  final CreateDestinyLoadoutFromEquippedBloc bloc;
  final CreateDestinyLoadoutFromEquippedBloc state;
  const CreateDestinyLoadoutFromEquippedView({
    super.key,
    required this.bloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final viewPadding = context.mediaQuery.viewPadding;
    return Scaffold(
      floatingActionButton: buildFab(context),
      body: Stack(
        children: [
          Container(
            color: context.theme.surfaceLayers.layer1,
            padding: EdgeInsets.only(top: viewPadding.top + kToolbarHeight),
            child: Column(children: [
              Expanded(
                  child: SingleChildScrollView(
                padding: EdgeInsets.all(4) + EdgeInsets.only(bottom: 200),
                child: buildBody(context),
              )),
            ]),
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
    return Container(
        height: barBackgroundHeight,
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
                  state.selectedColorHash,
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
                    Container(
                      height: kToolbarHeight,
                      alignment: Alignment.center,
                      child: ManifestText<DestinyLoadoutNameDefinition>(
                        state.selectedNameHash,
                        textExtractor: (def) => def.name?.toUpperCase(),
                        style: context.textTheme.itemNameHighDensity.copyWith(fontSize: 16),
                      ),
                    ),
                    Expanded(child: Container()),
                    Container(
                      width: kToolbarHeight,
                      height: kToolbarHeight,
                      child: ManifestImageWidget<DestinyLoadoutIconDefinition>(
                        state.selectedIconHash,
                        urlExtractor: (def) => def.iconImagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    Container(
                      width: 16,
                    ),
                  ],
                )),
          ],
        ));
  }

  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildCharacter(context),
        HeaderWidget(child: Text("Customize".translate(context).toUpperCase())),
        Container(height: 4),
        buildManageColor(context),
        buildManageIcon(context),
        buildManageName(context),
        Container(height: 24),
        HeaderWidget(child: Text("Items".translate(context).toUpperCase())),
        buildItems(context),
      ],
    );
  }

  Widget buildCharacter(BuildContext context) {
    final character = state.character;
    if (character == null) return Container();
    return Container(
      height: 72,
      child: LoadoutCharacterHeaderWidget(character),
    );
  }

  Widget buildManageColor(BuildContext context) {
    final colorHashes = state.availableColorHashes;
    if (colorHashes == null) return Container();
    final selected = state.selectedColorHash;
    final selectedIndex = selected != null ? colorHashes.indexOf(selected) : 0;
    return Container(
        padding: EdgeInsets.all(4),
        child: PaginatedScrollableGridView.withExpectedItemSize(
          colorHashes,
          itemBuilder: (hash) => buildSelectableButton(
            context,
            selected: hash == selected,
            onTap: () => bloc.selectedColorHash = hash,
            child: ManifestImageWidget<DestinyLoadoutColorDefinition>(
              hash,
              urlExtractor: (def) => def.colorImagePath,
            ),
          ),
          gridSpacing: 4,
          maxRows: 1,
          expectedCrossAxisSize: 48,
          initialFocus: selectedIndex,
        ));
  }

  Widget buildManageIcon(BuildContext context) {
    final iconHashes = state.availableIconHashes;
    if (iconHashes == null) return Container();
    final selected = state.selectedIconHash;
    final selectedIndex = selected != null ? iconHashes.indexOf(selected) : 0;
    return Container(
        padding: EdgeInsets.all(4),
        child: PaginatedScrollableGridView.withExpectedItemSize(
          iconHashes,
          itemBuilder: (hash) => buildSelectableButton(
            context,
            selected: hash == selected,
            onTap: () => bloc.selectedIconHash = hash,
            child: ManifestImageWidget<DestinyLoadoutIconDefinition>(
              hash,
              urlExtractor: (def) => def.iconImagePath,
            ),
          ),
          gridSpacing: 4,
          maxRows: 1,
          expectedCrossAxisSize: 48,
          initialFocus: selectedIndex,
        ));
  }

  Widget buildManageName(BuildContext context) {
    final nameHashes = state.availableNameHashes;
    if (nameHashes == null) return Container();
    final selected = state.selectedNameHash;
    final selectedIndex = selected != null ? nameHashes.indexOf(selected) : 0;
    return Container(
        padding: EdgeInsets.all(4),
        child: PaginatedScrollableGridView.withExpectedItemSize(
          nameHashes,
          itemBuilder: (hash) => buildSelectableTextButton(
            context,
            selected: hash == selected,
            onTap: () => bloc.selectedNameHash = hash,
            child: Container(
              padding: EdgeInsets.all(4),
              child: ManifestText<DestinyLoadoutNameDefinition>(
                hash,
                textExtractor: (def) => def.name,
                style: context.textTheme.itemNameHighDensity,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          gridSpacing: 4,
          maxRows: 3,
          expectedCrossAxisSize: 120,
          itemMainAxisExtent: 32,
          initialFocus: selectedIndex,
        ));
  }

  Widget buildSelectableButton(
    BuildContext context, {
    required Widget child,
    bool selected = false,
    VoidCallback? onTap,
  }) =>
      Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.5,
                color: selected ? context.theme.onSurfaceLayers : context.theme.onSurfaceLayers.layer3,
              ),
            ),
            child: child,
          ),
          Material(
            color: selected ? Colors.transparent : Colors.black26,
            child: InkWell(onTap: onTap),
          ),
        ],
      );

  Widget buildSelectableTextButton(
    BuildContext context, {
    required Widget child,
    bool selected = false,
    VoidCallback? onTap,
  }) =>
      Stack(
        fit: StackFit.expand,
        children: [
          Container(
            margin: EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? context.theme.primaryLayers : context.theme.surfaceLayers.layer3,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: 2,
                color: selected ? context.theme.onSurfaceLayers : Colors.transparent,
              ),
            ),
            child: child,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap),
          ),
        ],
      );

  Widget buildItems(BuildContext context) {
    final items = state.items;
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
    if (item == null) return buildItemNotFound(context);
    return DestinyLoadoutItemWidget(item);
  }

  Widget buildItemNotFound(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: context.theme.onSurfaceLayers.layer3, width: 2)),
              child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                _notFoundIconHash,
                color: context.theme.errorLayers.layer3,
              ),
            ),
            Container(
              width: 16,
            ),
            Text("Item not found".translate(context)),
          ],
        ));
  }

  Widget buildFab(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (state.canSave)
          actionButton(
            context,
            label: "Save Loadout".translate(context),
            onTap: () => bloc.saveLoadout(),
          ),
      ],
    );
  }

  Widget actionButton(
    BuildContext context, {
    required String label,
    Color? color,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    color ??= context.theme.primaryLayers;
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.textTheme.button,
                ),
                if (icon != null)
                  Container(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(icon, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
