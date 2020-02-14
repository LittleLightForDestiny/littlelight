import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:json_annotation/json_annotation.dart';

part 'wish_list.g.dart';

enum WishlistTag { PVP, PVE, Bungie, Trash }

@JsonSerializable()
class WishlistBuild {
  String identifier;
  Set<int> perks = Set();
  Set<WishlistTag> tags = Set();
  Set<String> notes = Set();
  WishlistBuild({this.identifier, this.perks, this.tags, this.notes});

  factory WishlistBuild.builder({
    String identifier,
    Set<int> perks,
    Set<WishlistTag> specialties,
    Set<String> notes,
  }) {
    return WishlistBuild(
        identifier: identifier,
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
  Map<String, WishlistBuild> builds = Map();
  WishlistItem({this.itemHash, this.builds, this.perks});

  factory WishlistItem.builder({
    int itemHash,
    Map<int, Set<WishlistTag>> perks,
    Map<String, WishlistBuild> builds,
  }) {
    return WishlistItem(
        itemHash: itemHash, perks: perks ?? Map(), builds: builds ?? Map());
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
  @JsonKey(defaultValue:true)
  bool isDefault;

  Wishlist({
    this.url,
    this.localFilename,
    this.name,
    this.description,
    this.updatedAt,
    this.type,
    this.isDefault=false
  });

  String get filename{
    if(localFilename!=null) return localFilename;
    localFilename = (md5.convert(Utf8Encoder().convert(url)).toString() + ".txt");
    return localFilename;
  }

  factory Wishlist.fromJson(dynamic json) {
    return _$WishlistFromJson(json);
  }

  factory Wishlist.defaults(){
    return Wishlist(
      url: "https://raw.githubusercontent.com/LittleLightForDestiny/dim-wish-list-sources/master/voltron.txt",
      name: "DIM's/48klocs voltron.txt",
      type: WishlistType.DimWishlist,
      description: "This is a compiled collection of god/recommended rolls from top community minds.\nContributions from: u/Mercules904, u/pandapaxxy, u/HavocsCall, and @chrisfried. \nCompiled into one list by u/48klocs / @48klocs",
      isDefault: true
    );
  }

  dynamic toJson() {
    return _$WishlistToJson(this);
  }
}
