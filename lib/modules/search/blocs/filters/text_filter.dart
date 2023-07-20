import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/core/blocs/loadouts/loadouts.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/text_filter_options.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/string/remove_diacritics.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';
import 'package:provider/provider.dart';
import 'base_item_filter.dart';

extension on List<String> {
  bool searchMatches(String str) {
    if (this.length == 1 && this.first.length <= 3) {
      return str.startsWith(first);
    }
    return this.every((w) => str.contains(w));
  }
}

class TextFilter extends BaseItemFilter<TextFilterOptions> with ManifestConsumer, WishlistsConsumer {
  List<Loadout>? loadouts;
  ItemNotesBloc? itemNotesBloc;
  TextFilter({initialText = ""}) : super(TextFilterOptions());

  @override
  Future<List<DestinyItemInfo>> filter(BuildContext context, List<DestinyItemInfo> items) async {
    loadouts = context.read<LoadoutsBloc>().loadouts;
    itemNotesBloc = context.read<ItemNotesBloc>();
    return super.filter(context, items);
  }

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final searchString = data.value;
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

    final damageTypeDef = await manifest.getDefinition<DestinyDamageTypeDefinition>(def.defaultDamageTypeHash);
    final damageTypeName = removeDiacritics(damageTypeDef?.displayProperties?.name?.toLowerCase());

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

    final plugHashes = Set<int?>.from(socketPlugHashes + reusablePlugHashes);
    final plugDefinitions = await manifest.getDefinitions<DestinyInventoryItemDefinition>(plugHashes);
    final plugNames = plugHashes.map((h) {
      final plugDef = plugDefinitions[h];
      return removeDiacritics(plugDef?.displayProperties?.name?.toLowerCase().trim() ?? "");
    });

    final wishlistBuildNotes = wishlistsService.getWishlistBuildNotes(itemHash: hash, reusablePlugs: reusablePlugs).map(
          (e) => e.toLowerCase(),
        );

    final wishlistTags = wishlistsService.getWishlistBuildTags(itemHash: hash, reusablePlugs: reusablePlugs);
    final wishlistTagNames = wishlistTags.map((t) => t.name.toLowerCase());

    final loadoutNames = loadouts
        ?.where((l) => instanceId != null ? l.containsItem(instanceId) : false) //
        .map((l) => l.name.toLowerCase().replaceDiacritics());

    final customName = itemNotesBloc?.customNameFor(hash, instanceId)?.toLowerCase();

    return terms.every((t) {
      var words = t.split(" ");
      final matchesName = words.searchMatches(name);
      if (matchesName) return true;

      final matchesCustomName = words.searchMatches(customName ?? "");
      if (matchesCustomName) return true;

      final matchesItemTypes = words.searchMatches(itemType);
      if (matchesItemTypes) return true;

      final matchesDamageType = words.searchMatches(damageTypeName);
      if (matchesDamageType) return true;

      final matchesLoadoutNames = loadoutNames?.any((l) => words.searchMatches(l)) ?? false;
      if (matchesLoadoutNames) return true;

      final matchesPlugs = plugNames.any((plugName) => words.searchMatches(plugName));
      if (matchesPlugs) return true;

      final matchesWishlistsTags = wishlistTagNames.any((t) => words.searchMatches(t));
      if (matchesWishlistsTags) return true;

      final matchesWishlistNotes = wishlistBuildNotes.any((n) => words.searchMatches(n));
      if (matchesWishlistNotes) return true;

      return false;
    });
  }
}
