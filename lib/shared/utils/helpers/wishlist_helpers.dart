import 'package:little_light/models/parsed_wishlist.dart';

typedef MappedWishlistBuilds = Map<String, Map<WishlistTag, List<ParsedWishlistBuild>>>;
typedef MappedWishlistNotes = Map<String, Map<String, Set<WishlistTag>>>;

Map<String, Map<WishlistTag, List<ParsedWishlistBuild>>> organizeWishlistBuilds(Iterable<ParsedWishlistBuild> builds) {
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

Map<String, Map<String, Set<WishlistTag>>> organizeWishlistNotes(Iterable<ParsedWishlistBuild> builds) {
  final result = <String, Map<String, Set<WishlistTag>>>{};
  for (final build in builds) {
    final notes = build.description;
    if (notes == null || notes.isEmpty) continue;
    final wishlistName = build.originalWishlist ?? "";
    final wishlist = result[wishlistName] ??= {};
    final tags = wishlist[notes] ??= <WishlistTag>{};
    tags.addAll(build.tags);
  }
  return result;
}
