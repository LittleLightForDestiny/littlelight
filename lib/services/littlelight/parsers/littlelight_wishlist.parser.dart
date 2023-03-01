import 'dart:convert';

import 'package:little_light/models/littlelight_wishlist.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/services/littlelight/parsers/wishlists.base.parser.dart';

class LittleLightWishlistParser implements WishlistBaseParser {
  @override
  Future<List<ParsedWishlistBuild>> parse(String content) async {
    final json = jsonDecode(content);
    final sourceWishlist = LittleLightWishlist.fromJson(json);
    return sourceWishlist.data
        .map((sourceBuild) => ParsedWishlistBuild(
            hash: sourceBuild.hash,
            name: sourceBuild.name,
            description: sourceBuild.description,
            plugs: parsePlugs(sourceBuild.plugs),
            tags: parseTags(sourceBuild.tags),
            originalWishlist: sourceBuild.originalWishlist))
        .toList();
  }

  List<Set<int>> parsePlugs(List<List<int>> plugs) =>
      plugs.map((p) => Set<int>.from(p)).toList();

  Set<WishlistTag> parseTags(List<String> tags) {
    return tags
        .map((t) {
          switch (t.toLowerCase()) {
            case "godpve":
            case "god-pve":
              return WishlistTag.GodPVE;
            case "pve":
              return WishlistTag.PVE;
            case "godpvp":
            case "god-pvp":
              return WishlistTag.GodPVP;
            case "pvp":
              return WishlistTag.PVP;
            case "curated":
            case "bungie":
              return WishlistTag.Bungie;

            case "trash":
              return WishlistTag.Trash;

            case "mouse":
            case "mnk":
              return WishlistTag.Mouse;

            case "controller":
              return WishlistTag.Controller;
          }
          return null;
        })
        .whereType<WishlistTag>()
        .toSet();
  }
}
