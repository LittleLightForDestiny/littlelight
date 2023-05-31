import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/item_details/blocs/item_details.bloc.dart';
import 'package:little_light/modules/item_details/widgets/details_energy_meter.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_actions.dart';
import 'package:little_light/modules/item_details/widgets/details_item_collectible_info.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_description.dart';
import 'package:little_light/modules/item_details/widgets/details_item_duplicates.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_intrinsic_perk.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_lore.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_mods.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_notes.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_perks.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_progress.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_quest_info.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_stats.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_tags.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_transfer_block.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_cover.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_wishlist_builds.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_wishlist_info.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_lock_status.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_wishlist_notes.widget.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_bottom_gradient.widget.dart';
import 'package:little_light/shared/widgets/notifications/busy_indicator_line.widget.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';
import 'package:little_light/shared/widgets/selection/selected_items.widget.dart';

abstract class BaseItemDetailsView extends StatelessWidget {
  final ItemDetailsBloc bloc;
  final ItemDetailsBloc state;
  final SocketControllerBloc socketState;
  final SelectionBloc selectionState;

  BaseItemDetailsView(this.bloc, this.state, this.socketState, this.selectionState);

  @override
  Widget build(BuildContext context) {
    return buildPortrait(context);
  }

  Widget buildPortrait(BuildContext context) {
    final hash = state.itemHash;
    if (hash == null) return Container();
    final footer = buildFooter(context);
    return Scaffold(
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  buildBody(context, hasFooter: footer != null),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    right: 0,
                    child: buildNotificationWidget(context, hasFooter: footer != null),
                  ),
                ],
              ),
            ),
            footer,
          ].whereType<Widget>().toList()),
    );
  }

  Widget buildBody(BuildContext context, {required bool hasFooter}) {
    return CustomScrollView(
      slivers: [
        DetailsItemCoverWidget(),
        buildDescription(context),
        buildWishlistInfo(context),
        buildLockState(context),
        buildActions(context),
        buildDuplicates(context),
        ...buildIntrinsicPerks(context),
        ...buildArmorEnergy(context),
        buildStats(context),
        ...buildSupers(context),
        ...buildAbilities(context),
        ...buildReusablePerks(context),
        ...buildMods(context),
        buildWishlistBuilds(context),
        buildWishlistNotes(context),
        buildItemProgress(context),
        buildQuestSteps(context),
        buildItemNotes(context),
        buildItemTags(context),
        buildLore(context),
        buildCollectibleInfo(context),
        buildEmptySpace(context, hasFooter: hasFooter),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildNotificationWidget(BuildContext context, {required bool hasFooter}) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final useLoadingFooter = bottomPadding > 0 && !hasFooter;
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomRight,
          child: const NotificationsWidget(),
          padding: EdgeInsets.all(8),
        ),
        useLoadingFooter
            ? SizedBox(height: bottomPadding, child: BusyIndicatorBottomGradientWidget())
            : BusyIndicatorLineWidget()
      ],
    );
  }

  Widget? buildDescription(BuildContext context) {
    final itemHash = state.itemHash;
    if (itemHash == null) return null;
    return SliverToBoxAdapter(
      child: DetailsItemDescriptionWidget(itemHash, item: state.item),
    );
  }

  Widget? buildWishlistInfo(BuildContext context) {
    final tags = state.wishlistTags;
    if (tags == null || tags.isEmpty) return null;
    return SliverToBoxAdapter(
      child: DetailsWishlistInfoWidget(tags),
    );
  }

  Widget? buildLockState(BuildContext context) {
    final locked = state.isLocked;
    if (locked == null) return null;
    final busy = state.isLockBusy;
    return SliverToBoxAdapter(
      child: DetailsLockStatusWidget(
        locked,
        onChange: (locked) => bloc.changeLockState(locked),
        busy: busy,
      ),
    );
  }

  Widget? buildActions(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    final isInstance = state.item?.instanceId != null;
    final canViewInCollection = isInstance && (def?.equippable ?? false);
    final canAddToLoadout = isInstance &&
        (def?.equippable ?? false) &&
        InventoryBucket.loadoutBucketHashes.contains(
          def?.inventory?.bucketTypeHash,
        );
    if (!canViewInCollection && !canAddToLoadout) return null;
    return SliverToBoxAdapter(
        child: DetailsItemActionsWidget(
      onAddToLoadout: canAddToLoadout ? bloc.addToLoadout : null,
      onViewInCollections: canViewInCollection ? bloc.viewInCollections : null,
    ));
  }

  List<Widget> buildIntrinsicPerks(BuildContext context) {
    final intrinsic = socketState.getSocketCategories(DestinySocketCategoryStyle.Intrinsic) ?? [];
    final largePerks = socketState.getSocketCategories(DestinySocketCategoryStyle.LargePerk) ?? [];
    final all = intrinsic + largePerks;
    return all
        .map(
          (e) => SliverToBoxAdapter(child: DetailsItemIntrinsicPerkWidget(e)),
        )
        .toList();
  }

  Widget buildStats(BuildContext context) {
    return SliverToBoxAdapter(child: DetailsItemStatsWidget());
  }

  List<Widget> buildReusablePerks(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Reusable) ?? [];
    final all = reusable;
    return all
        .map(
          (e) => SliverToBoxAdapter(child: DetailsItemPerksWidget(e)),
        )
        .toList();
  }

  List<Widget> buildSupers(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Supers) ?? [];
    final all = reusable;
    return all
        .map(
          (e) => SliverToBoxAdapter(child: DetailsItemPerksWidget(e)),
        )
        .toList();
  }

  List<Widget> buildAbilities(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Abilities) ?? [];
    final all = reusable;
    return all
        .map(
          (e) => SliverToBoxAdapter(child: DetailsItemModsWidget(e)),
        )
        .toList();
  }

  List<Widget> buildMods(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.Consumable) ?? [];
    final all = reusable;
    return all
        .map(
          (e) => SliverToBoxAdapter(child: DetailsItemModsWidget(e)),
        )
        .toList();
  }

  List<Widget> buildArmorEnergy(BuildContext context) {
    final reusable = socketState.getSocketCategories(DestinySocketCategoryStyle.EnergyMeter) ?? [];
    final all = reusable;
    return all
        .map(
          (e) => SliverToBoxAdapter(child: DetailsEnergyMeterWidget(e)),
        )
        .toList();
  }

  Widget? buildDuplicates(BuildContext context) {
    final items = state.duplicates;
    if (items == null || items.isEmpty) return null;
    return SliverToBoxAdapter(child: DetailsItemDuplicatesWidget(items));
  }

  Widget? buildItemProgress(BuildContext context) {
    final item = state.item;
    if (item == null) return null;
    final def = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    if (def?.itemType == DestinyItemType.QuestStep) return null;
    final objectives = def?.objectives?.objectiveHashes;
    if (objectives == null || objectives.isEmpty) return null;
    return SliverToBoxAdapter(
      child: DetailsItemProgressWidget(
        item,
        canTrack: state.canTrack,
      ),
    );
  }

  Widget? buildQuestSteps(BuildContext context) {
    final item = state.item;
    if (item == null) return null;
    final def = context.definition<DestinyInventoryItemDefinition>(state.itemHash);
    if (def?.itemType != DestinyItemType.QuestStep) return null;
    if (def?.objectives?.questlineItemHash == null) return null;
    return SliverToBoxAdapter(
      child: DetailsItemQuestInfoWidget(
        item,
        canTrack: state.canTrack,
      ),
    );
  }

  Widget? buildItemNotes(BuildContext context) {
    return SliverToBoxAdapter(
        child: DetailsItemNotesWidget(
      customName: state.customName,
      notes: state.itemNotes,
      onEditTap: state.editNotes,
    ));
  }

  Widget? buildItemTags(BuildContext context) {
    return SliverToBoxAdapter(
        child: DetailsItemTagsWidget(
      tags: state.tags,
      onRemoveTag: state.removeTag,
      onAddTap: state.editTags,
    ));
  }

  Widget? buildWishlistBuilds(BuildContext context) {
    final builds = state.wishlistBuilds;
    if (builds == null) return null;
    return SliverToBoxAdapter(
        child: DetailsWishlistBuildsWidget(
      builds,
      allAvailablePlugHashes: socketState.allAvailablePlugHashes,
      allSelectedPlugHashes: socketState.allSelectedPlugHashes,
      allEquippedPlugHashes: socketState.allEquippedPlugHashes,
      viewAllBuilds: bloc.showAllWishlistBuilds,
      enableViewAllBuilds: true,
      onToggleViewAllBuilds: (value) => bloc.showAllWishlistBuilds = value,
    ));
  }

  Widget? buildWishlistNotes(BuildContext context) {
    final notes = state.wishlistNotes;
    if (notes == null) return null;
    return SliverToBoxAdapter(
        child: DetailsWishlistNotesWidget(
      notes,
      viewAllNotes: bloc.showAllWishlistNotes,
      enableViewAllNotes: true,
      onToggleViewAllNotes: (value) => bloc.showAllWishlistNotes = value,
    ));
  }

  Widget? buildLore(BuildContext context) {
    final hash = state.itemHash;
    if (hash == null) return null;
    return SliverToBoxAdapter(
        child: DetailsItemLoreWidget(
      hash,
    ));
  }

  Widget? buildCollectibleInfo(BuildContext context) {
    final hash = state.itemHash;
    if (hash == null) return null;
    return SliverToBoxAdapter(
        child: DetailsItemCollectibleInfoWidget(
      hash,
    ));
  }

  Widget buildEmptySpace(BuildContext context, {required bool hasFooter}) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 64 + (!hasFooter ? bottomPadding : 0),
      ),
    );
  }

  Widget? buildFooter(BuildContext context) {
    final mqPadding = MediaQuery.of(context).viewPadding;
    final selection = selectionState.selectedItems;
    if (selection.isNotEmpty) {
      return Container(
          color: context.theme.surfaceLayers.layer1,
          child: Column(
            children: [
              SelectedItemsWidget(),
              SizedBox(
                height: mqPadding.bottom,
                child: BusyIndicatorBottomGradientWidget(),
              ),
            ],
          ));
    }
    final item = state.item;
    if (item == null) return null;
    if ((state.transferDestinations?.isEmpty ?? true) && (state.equipDestinations?.isEmpty ?? true)) return null;
    return Container(
      color: context.theme.surfaceLayers.layer1,
      child: Column(children: [
        DetailsTransferBlockWidget(
          item,
          transferDestinations: state.transferDestinations,
          equipDestinations: state.equipDestinations,
          onAction: bloc.onTransferAction,
        ),
        SizedBox(
          height: mqPadding.bottom,
          child: BusyIndicatorBottomGradientWidget(),
        ),
      ]),
    );
  }
}
