import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/wishlist_tag_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:provider/provider.dart';

class InventoryItemPerks extends StatelessWidget with WishlistsConsumer {
  final DestinyItemInfo itemInfo;
  final int categoryHash;
  final double plugSize;
  final bool includeUnequipped;
  InventoryItemPerks(
    this.itemInfo, {
    required this.categoryHash,
    this.plugSize = 20,
    this.includeUnequipped = false,
  });
  @override
  Widget build(BuildContext context) {
    final definition = context.definition<DestinyInventoryItemDefinition>(itemInfo.itemHash);
    final sockets = itemInfo.sockets;
    final socketCategory = definition?.sockets?.socketCategories //
        ?.firstWhereOrNull((c) => c.socketCategoryHash == categoryHash);
    final socket = socketCategory?.socketIndexes;
    final reusable = itemInfo.reusablePlugs;
    if (socket == null || socket.isEmpty) return Container();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: socket //
          .where((p) => (sockets?[p].isVisible ?? false) && (sockets?[p].isEnabled ?? false))
          .map((p) => includeUnequipped
              ? buildSocket(context, reusable?["$p"], definition?.sockets?.socketEntries?[p])
              : buildPlug(context, sockets?[p].plugHash))
          .whereType<Widget>()
          .toList(),
    );
  }

  Widget? buildSocket(
      BuildContext context, List<DestinyItemPlugBase>? plugs, DestinyItemSocketEntryDefinition? socketDef) {
    if (plugs == null) {
      if (socketDef?.plugSources?.contains(SocketPlugSources.ProfilePlugSet) ?? false)
        return buildSocketFromPlugSet(context, socketDef);
      return Container();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: plugs.map((e) => buildPlug(context, e.plugItemHash)).whereType<Widget>().toList(),
    );
  }

  Widget? buildSocketFromPlugSet(BuildContext context, DestinyItemSocketEntryDefinition? socketDef) {
    final profile = context.read<ProfileBloc>();
    final hashes = {socketDef?.reusablePlugSetHash, socketDef?.randomizedPlugSetHash}
        .whereType<int>()
        .map((plugSetHash) => profile.getProfilePlugSets(plugSetHash))
        .whereType<List<DestinyItemPlug>>()
        .expand((plugSet) => (plugSet)
            .where((plugDef) {
              final canInsert = plugDef.canInsert ?? false;
              final enabled = plugDef.enabled ?? false;
              return canInsert && enabled;
            })
            .map((plugDef) => plugDef.plugItemHash)
            .whereType<int>())
        .toSet();
    final reusablePlugHashes = socketDef?.reusablePlugItems?.map((e) => e.plugItemHash).whereType<int>();
    if (reusablePlugHashes != null) hashes.addAll(reusablePlugHashes);
    if (hashes.isEmpty) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: hashes.take(3).map((e) => buildPlug(context, e)).whereType<Widget>().toList(),
    );
  }

  Widget? buildPlug(BuildContext context, int? plugHash) {
    if (plugHash == null) return null;
    // Filter out kill trackers and origin perks
    final definition = context.definition<DestinyInventoryItemDefinition>(plugHash);
    final category = definition?.plug?.plugCategoryIdentifier;
    if (category == 'origins' || (category?.endsWith('masterworks.trackers') ?? false)) return null;
    return Stack(
        fit: StackFit.loose,
        children: [
          Positioned.fill(child: buildWishlistBackground(context, plugHash) ?? Container()),
          SizedBox(
            width: plugSize,
            height: plugSize,
            child: ManifestImageWidget<DestinyInventoryItemDefinition>(plugHash),
          ),
        ].whereType<Widget>().toList());
  }

  Widget? buildWishlistBackground(BuildContext context, int plugHash) {
    final itemHash = itemInfo.itemHash;
    if (itemHash == null) return null;
    final tags = wishlistsService.getPlugTags(itemHash, plugHash);
    if (tags.isEmpty) return null;
    final borderRadius = BorderRadius.circular(4);
    const borderWidth = 1.0;
    if (tags.isAllAround) {
      final isGodPvE = tags.contains(WishlistTag.GodPVE);
      final isGodPvP = tags.contains(WishlistTag.GodPVP);
      final pveBorderColor = (isGodPvE ? WishlistTag.GodPVE : WishlistTag.PVE).getBorderColor(context);
      final pvpBorderColor = (isGodPvP ? WishlistTag.GodPVP : WishlistTag.PVP).getBorderColor(context);

      return Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: [pveBorderColor, pvpBorderColor],
                stops: const [.49, .51],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(borderWidth),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: [WishlistTag.PVE.getBorderColor(context), WishlistTag.PVP.getBorderColor(context)],
                stops: const [.49, .51],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      );
    }
    if (tags.isPvE) {
      final isGodPvE = tags.contains(WishlistTag.GodPVE);
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: WishlistTag.PVE.getColor(context),
          border: isGodPvE ? Border.all(width: borderWidth, color: WishlistTag.GodPVE.getBorderColor(context)) : null,
        ),
      );
    }
    if (tags.isPvP) {
      final isGodPvE = tags.contains(WishlistTag.GodPVP);
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: WishlistTag.PVP.getColor(context),
          border: isGodPvE ? Border.all(width: borderWidth, color: WishlistTag.GodPVP.getBorderColor(context)) : null,
        ),
      );
    }
    return null;
  }
}
