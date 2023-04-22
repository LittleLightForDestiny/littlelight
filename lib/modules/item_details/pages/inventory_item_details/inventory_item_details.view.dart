import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/item_details/widgets/details_energy_meter.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_collectible_info.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_intrinsic_perk.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_lore.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_mods.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_notes.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_perks.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_stats.widget.dart';
import 'package:little_light/modules/item_details/widgets/details_item_tags.widget.dart';
import 'package:little_light/modules/item_details/widgets/item_details_cover.widget.dart';
import 'package:little_light/modules/item_details/widgets/lock_status.widget.dart';
import 'package:little_light/shared/blocs/socket_controller/socket_controller.bloc.dart';
import 'package:little_light/shared/widgets/notifications/notifications.widget.dart';

import '../../blocs/item_details.bloc.dart';

class InventoryItemDetailsView extends StatelessWidget {
  final ItemDetailsBloc bloc;
  final ItemDetailsBloc state;
  final SocketControllerBloc socketState;

  InventoryItemDetailsView(this.bloc, this.state, this.socketState);

  @override
  Widget build(BuildContext context) {
    return buildPortrait(context);
  }

  Widget buildPortrait(BuildContext context) {
    final hash = state.itemHash;
    if (hash == null) return Container();
    return Scaffold(
      body: Stack(
        children: [
          buildBody(context),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: buildNotificationWidget(context),
          ),
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        ItemDetailsCoverWidget(),
        buildTransferOptions(context),
        buildLockState(context),
        ...buildIntrinsicPerks(context),
        ...buildArmorEnergy(context),
        buildStats(context),
        ...buildSupers(context),
        ...buildAbilities(context),
        ...buildReusablePerks(context),
        ...buildMods(context),
        buildItemNotes(context),
        buildItemTags(context),
        buildLore(context),
        buildCollectibleInfo(context),
        buildEmptySpace(context),
      ].whereType<Widget>().toList(),
    );
  }

  Widget buildNotificationWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomRight,
          child: const NotificationsWidget(),
          padding: EdgeInsets.all(8),
        ),
      ],
    );
  }

  Widget? buildTransferOptions(BuildContext context) {
    // final item = state.item;
    // if (item == null) return null;
    // return SliverToBoxAdapter(
    //   child: DetailsTransferBlockWidget(
    //     item,
    //     transferDestinations: state.transferDestinations,
    //     equipDestinations: state.equipDestinations,
    //   ),
    // );
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
          (e) => SliverToBoxAdapter(child: DetailsItemPerksWidget(e)),
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

  Widget buildItemNotes(BuildContext context) {
    return SliverToBoxAdapter(
        child: DetailsItemNotesWidget(
      customName: state.customName,
      notes: state.itemNotes,
      onEditTap: state.editNotes,
    ));
  }

  Widget buildItemTags(BuildContext context) {
    return SliverToBoxAdapter(
        child: DetailsItemTagsWidget(
      tags: state.tags,
      onRemoveTag: state.removeTag,
      onAddTap: state.editTags,
    ));
  }

  Widget buildLore(BuildContext context) {
    final hash = state.itemHash;
    if (hash == null) return Container();
    return SliverToBoxAdapter(
        child: DetailsItemLoreWidget(
      hash,
    ));
  }

  Widget buildCollectibleInfo(BuildContext context) {
    final hash = state.itemHash;
    if (hash == null) return Container();
    return SliverToBoxAdapter(
        child: DetailsItemCollectibleInfoWidget(
      hash,
    ));
  }

  Widget buildEmptySpace(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 128,
      ),
    );
  }
}
