import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:json_annotation/json_annotation.dart';

part 'wish_list.g.dart';

enum WishlistTag { GodPVE, GodPVP, PVE, PVP, Bungie, Trash }

List<Set<int>> _jsonPlugsFromJson(List<dynamic> json) {
  return json
      .map((e) => (e as List<dynamic>).map((e) => int.parse(e)).toSet())
      .toList();
}

@JsonSerializable()
class LittleLightWishlist {
  String name;
  String description;
  List<LittleLightWishlistItem> data;

  LittleLightWishlist({this.name, this.description, this.data});

  factory LittleLightWishlist.fromJson(dynamic json) {
    return _$LittleLightWishlistFromJson(json);
  }

  dynamic toJson() {
    return _$LittleLightWishlistToJson(this);
  }
}

@JsonSerializable()
class LittleLightWishlistItem {
  String name;
  String description;
  List<List<int>> plugs;
  int hash;
  List<String> tags;
  List<String> authors;
  LittleLightWishlistItem(
    this.name,
    this.description,
    this.plugs,
    this.hash,
    this.tags,
    this.authors,
  );

  factory LittleLightWishlistItem.fromJson(dynamic json) {
    return _$LittleLightWishlistItemFromJson(json);
  }

  dynamic toJson() {
    return _$LittleLightWishlistItemToJson(this);
  }
}

@JsonSerializable()
class WishlistBuild {
  String name;
  @JsonKey(fromJson: _jsonPlugsFromJson)
  List<Set<int>> perks = [];
  Set<WishlistTag> tags = Set();
  Set<String> notes = Set();
  WishlistBuild({this.name, this.perks, this.tags, this.notes});

  factory WishlistBuild.builder({
    String name,
    List<Set<int>> perks,
    Set<WishlistTag> specialties,
    Set<String> notes,
  }) {
    return WishlistBuild(
        name: name,
        perks: perks ?? Set(),
        tags: specialties ?? Set(),
        notes: notes ?? Set());
  }

  factory WishlistBuild.fromJson(dynamic json) {
    return _$WishlistBuildFromJson(json);
  }

  dynamic toJson() {
    return _$WishlistBuildToJson(this);
  }
}

@JsonSerializable()
class WishlistItem {
  int itemHash;
  Map<int, Set<WishlistTag>> perks = Map();
  List<WishlistBuild> builds = [];
  WishlistItem({this.itemHash, this.builds, this.perks});

  factory WishlistItem.builder({
    int itemHash,
    Map<int, Set<WishlistTag>> perks,
    Map<String, WishlistBuild> builds,
  }) {
    return WishlistItem(
        itemHash: itemHash, perks: perks ?? Map(), builds: builds ?? []);
  }

  factory WishlistItem.fromJson(dynamic json) {
    return _$WishlistItemFromJson(json);
  }

  dynamic toJson() {
    return _$WishlistItemToJson(this);
  }
}

enum WishlistType {
  @JsonValue("DimWishlist")
  DimWishlist,
}

@JsonSerializable()
class Wishlist {
  String url;
  String localFilename;
  String name;
  String description;
  DateTime updatedAt;
  WishlistType type;

  Wishlist(
      {this.url,
      this.localFilename,
      this.name,
      this.description,
      this.updatedAt,
      this.type});

  String get filename {
    if (localFilename != null) return localFilename;
    localFilename =
        (md5.convert(Utf8Encoder().convert(url)).toString() + ".txt");
    return localFilename;
  }

  factory Wishlist.fromJson(dynamic json) {
    return _$WishlistFromJson(json);
  }

  factory Wishlist.defaults() {
    return Wishlist(
        url:
            "https://raw.githubusercontent.com/LittleLightForDestiny/littlelight_wishlists/master/littlelight_default.json",
        name: "Little Light default wishlist",
        type: WishlistType.DimWishlist,
        description:
            "basically a compilation of pandapaxxy's Weapons Breakdown");
  }

  dynamic toJson() {
    return _$WishlistToJson(this);
  }
}
