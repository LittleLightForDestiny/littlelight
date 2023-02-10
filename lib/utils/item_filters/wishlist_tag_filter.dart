// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'base_item_filter.dart';

class WishlistTagFilter extends BaseItemFilter<Set<WishlistTag>> with WishlistsConsumer, ProfileConsumer {
  WishlistTagFilter() : super(<WishlistTag>{}, <WishlistTag>{});

  @override
  Future<List<ItemWithOwner>> filter(List<ItemWithOwner> items,
      {Map<int, DestinyInventoryItemDefinition> definitions}) async {
    availableValues.clear();
    List<WishlistTag> tags = items
        .expand((i) {
          final reusable = profile.getItemReusablePlugs(i?.item?.itemInstanceId);
          final tags =
              wishlistsService.getWishlistBuildTags(itemHash: i?.item?.itemHash, reusablePlugs: reusable)?.toList();
          if (tags == null) return <WishlistTag>[];
          if (tags.isEmpty) return <WishlistTag>[null];
          return tags;
        })
        .toSet()
        .toList();
    tags.sort((a, b) => a?.index?.compareTo(b?.index ?? -1) ?? 0);
    availableValues = tags.toSet();
    available = availableValues.length > 1;
    value.retainAll(availableValues);
    if (value.isEmpty) return items;
    return super.filter(items, definitions: definitions);
  }

  @override
  bool filterItem(ItemWithOwner item, {Map<int, DestinyInventoryItemDefinition> definitions}) {
    final reusable = profile.getItemReusablePlugs(item?.item?.itemInstanceId);
    final tags =
        wishlistsService.getWishlistBuildTags(itemHash: item?.item?.itemHash, reusablePlugs: reusable)?.toList();
    if (value?.any((element) => tags?.contains(element) ?? false) ?? false) return true;
    if (value.contains(null) && tags.isEmpty) return true;
    return false;
  }
}
