//@dart=2.12
import 'dart:convert';

import 'package:little_light/models/littlelight_wishlist.dart';
import 'package:little_light/models/wish_list.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/littlelight/old.wishlists.service.dart';

class LittleLightWishlistParser {
  Future<LittleLightWishlist> parse(String text) async {
    var json = jsonDecode(text);
    var wishlist = LittleLightWishlist.fromJson(json);

    for (var item in wishlist.data) {
      var tags = parseTags(item.tags);
      OldWishlistsService().addToWishList(
          originalWishlist: item.originalWishlist ?? wishlist.name ?? "",
          name: item.name ?? "",
          hash: item.hash,
          perks: item.plugs,
          specialties: tags,
          notes: [item.description].whereType<String>().toSet());
    }
    return wishlist;
  }

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
