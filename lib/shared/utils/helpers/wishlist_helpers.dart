import 'package:little_light/models/parsed_wishlist.dart';

typedef MappedWishlists = Map<String, Map<WishlistTag, List<ParsedWishlistBuild>>>;

Map<String, Map<WishlistTag, List<ParsedWishlistBuild>>> organizeWishlists(Iterable<ParsedWishlistBuild> builds) {
  final result = <String, Map<WishlistTag, List<ParsedWishlistBuild>>>{};
  for (final build in builds) {
    final wishlistName = build.originalWishlist ?? "";
    final wishlist = result[wishlistName] ??= {};
    final tags = build.tags;
    for (final tag in tags) {
      final tagBuilds = wishlist[tag] ??= [];
      tagBuilds.add(build);
    }
  }
  return result;
}
