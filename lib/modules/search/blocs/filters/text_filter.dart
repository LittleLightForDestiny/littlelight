import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/blocs/loadouts.bloc.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/remove_diacritics.dart';
import 'package:provider/provider.dart';

import 'base_item_filter.dart';

class TextFilter extends BaseItemFilter<String?> with ManifestConsumer, WishlistsConsumer, ItemNotesConsumer {
  final BuildContext context;
  List<LoadoutItemIndex>? loadouts;
  TextFilter(this.context, {initialText = "", enabled = true}) : super(null, initialText, enabled: enabled);

  @override
  Future<List<DestinyItemInfo>> filter(List<DestinyItemInfo> items) async {
    loadouts = context.read<LoadoutsBloc>().loadouts;
    return super.filter(items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final searchString = value;
    if (searchString == null) return true;
    if (searchString.length == 0) return true;
    final hash = item.itemHash;
    final instanceId = item.instanceId;
    if (hash == null) return false;
    final terms = searchString.split(RegExp("[,.|]")).map((s) => removeDiacritics(s.toLowerCase().trim()));
    final def = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (def == null) return false;
    final name = removeDiacritics(def.displayProperties?.name?.toLowerCase().trim() ?? "");
    final itemType = removeDiacritics(def.itemTypeDisplayName?.toLowerCase().trim() ?? "");
    final sockets = item.sockets;
    final reusablePlugs = item.reusablePlugs;
    final socketPlugHashes = sockets?.map((s) => s.plugHash).toList() ?? <int>[];
    final reusablePlugHashes = reusablePlugs?.values.fold<List<int>>(<int>[], (hashes, plug) {
          final plugHashes = plug
              .map((e) => e.plugItemHash) //
              .whereType<int>()
              .toList(growable: false);
          return hashes + plugHashes;
        }) ??
        <int>[];

    final plugHashes = Set<int>.from(socketPlugHashes + reusablePlugHashes);
    final plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);

    final wishlistBuildNotes = wishlistsService.getWishlistBuildNotes(itemHash: hash, reusablePlugs: reusablePlugs);
    final wishlistTags = wishlistsService.getWishlistBuildTags(itemHash: hash, reusablePlugs: reusablePlugs);

    final loadoutNames = loadouts
        ?.where((l) => instanceId != null ? l.containsItem(instanceId) : false) //
        .map((l) => l.name);

    final customName = itemNotes.getNotesForItem(hash, instanceId)?.customName?.toLowerCase();

    return terms.every((t) {
      var words = t.split(" ");
      final matchesName = words.every((w) => name.contains(w));
      if (matchesName) return true;

      final matchesCustomName = words.every((w) => customName?.contains(w) ?? false);
      if (matchesCustomName) return true;

      final matchesItemTypes = words.every((w) => itemType.contains(w));
      if (matchesItemTypes) return true;

      final matchesLoadoutNames = loadoutNames != null
          ? words.every((w) => loadoutNames.any((l) => removeDiacritics(l.toLowerCase()).contains(w)))
          : false;
      if (matchesLoadoutNames) return true;

      final matchesPlugs = plugHashes.any((h) {
        final plugDef = plugDefinitions[h];
        final name = removeDiacritics(plugDef?.displayProperties?.name?.toLowerCase().trim() ?? "");
        if (words.every((w) => name.contains(w))) return true;
        return false;
      });

      if (matchesPlugs) return true;

      final matchesWishlistsTags = wishlistTags.any((t) => words.every((w) => t.toString().toLowerCase().contains(w)));
      if (matchesWishlistsTags) return true;

      final matchesWishlistNotes = wishlistBuildNotes.any((n) => words.every((w) => n.toLowerCase().contains(w)));
      if (matchesWishlistNotes) return true;

      return false;
    });
  }
}
