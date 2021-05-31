import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/remove_diacritics.dart';

import 'base_item_filter.dart';

class TextFilter extends BaseItemFilter<String> {
  List<Loadout> loadouts;
  TextFilter({initialText: "", enabled: true})
      : super(null, initialText, enabled: enabled);

  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    loadouts = await LoadoutsService().getLoadouts();
    return super.filter(items, definitions: definitions);
  }

  bool filterItem(ItemWithOwner item,
      {Map<int, DestinyInventoryItemDefinition> definitions}) {
    if ((this.value?.length ?? 0) < 1) return true;
    var _terms = value
        .split(RegExp("[,.|]"))
        .map((s) => removeDiacritics(s.toLowerCase().trim()))
        .toList(growable: false);
    var _def = definitions[item?.item?.itemHash];
    var name = removeDiacritics(
        _def?.displayProperties?.name?.toLowerCase()?.trim() ?? "");
    var itemType = removeDiacritics(
        _def?.itemTypeDisplayName?.toLowerCase()?.trim() ?? "");
    var sockets = ProfileService().getItemSockets(item?.item?.itemInstanceId);
    var reusablePlugs =
        ProfileService().getItemReusablePlugs(item?.item?.itemInstanceId);
    var plugHashes = Set<int>();
    plugHashes.addAll(sockets?.map((s) => s.plugHash)?.toSet() ?? Set());
    plugHashes.addAll(reusablePlugs?.values?.fold<List<int>>(
            [],
            (l, r) =>
                l.followedBy(r.map((e) => e.plugItemHash)).toList())?.toSet() ??
        Set<int>());
    var wishlistBuildNotes =
        WishlistsService().getWishlistBuildNotes(item.item);
    var wishlistTags = WishlistsService().getWishlistBuildTags(item: item.item);

    var loadoutNames = this.loadouts.where((l) {
      var equipped =
          l.equipped.where((e) => e.itemInstanceId == item.item.itemInstanceId);
      var unequipped = l.unequipped
          .where((e) => e.itemInstanceId == item.item.itemInstanceId);
      return equipped.length > 0 || unequipped.length > 0;
    }).map((l) => l.name ?? "");

    var customName = ItemNotesService()
            .getNotesForItem(item?.item?.itemHash, item?.item?.itemInstanceId)
            ?.customName
            ?.toLowerCase() ??
        "";

    return _terms.every((t) {
      var words = t.split(" ");
      if (words.every((w) => name.contains(w))) return true;
      if (words.every((w) => customName.contains(w))) return true;
      if (words.every((w) => itemType.contains(w))) return true;
      if (words.every((w) => loadoutNames.any(
          (l) => removeDiacritics(l.toLowerCase()).contains(w)))) return true;
      if (plugHashes.any((h) {
        var plugDef = definitions[h];
        var name = removeDiacritics(
            plugDef?.displayProperties?.name?.toLowerCase()?.trim() ?? "");
        if (words.every((w) => name.contains(w))) return true;
        return false;
      })) return true;
      if (wishlistTags?.any((t) =>
              words.every((w) => t.toString().toLowerCase().contains(w))) ??
          false) return true;
      if (wishlistBuildNotes
              ?.any((n) => words.every((w) => n.toLowerCase().contains(w))) ??
          false) return true;
      return false;
    });
  }
}
