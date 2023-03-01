import 'package:little_light/core/blocs/profile/destiny_item_info.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/search/blocs/filter_options/wishlist_tag_filter_options.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';

import 'base_item_filter.dart';

class WishlistTagFilter extends BaseItemFilter<WishlistTagFilterOptions>
    with WishlistsConsumer {
  WishlistTagFilter(Set<WishlistTag> values)
      : super(WishlistTagFilterOptions(values));

  @override
  Future<bool> filterItem(DestinyItemInfo item) async {
    final hash = item.itemHash;
    final reusablePlugs = item.reusablePlugs;
    if (hash == null) return false;

    final tags = wishlistsService.getWishlistBuildTags(
        itemHash: hash, reusablePlugs: reusablePlugs);
    if (tags.isEmpty) return false;
    return data.value.any((element) => tags.any((t) => t == element));
  }
}
