//@dart=2.12

import 'package:json_annotation/json_annotation.dart';

part 'parsed_wishlist.g.dart';

enum WishlistTag { GodPVE, GodPVP, PVE, PVP, Bungie, Trash, Mouse, Controller, UnknownEnumValue }

List<Set<int>> _jsonPlugsFromJson(List<dynamic> json) {
  return json.map((e) => (e as List<dynamic>).map((e) => int.parse(e)).toSet()).toList();
}

@JsonSerializable()
class ParsedWishlist {
  Map<int, ParsedWishlistItem> items;

  ParsedWishlist(this.items);

  factory ParsedWishlist.fromJson(dynamic json) {
    return _$ParsedWishlistFromJson(json);
  }

  dynamic toJson() {
    return _$ParsedWishlistToJson(this);
  }
}

@JsonSerializable()
class ParsedWishlistBuild {
  int? hash;
  String? name;

  @JsonKey(fromJson: _jsonPlugsFromJson)
  List<Set<int>> plugs;

  @JsonKey(unknownEnumValue: WishlistTag.UnknownEnumValue)
  Set<WishlistTag> tags;
  String? description;
  String? originalWishlist;

  ParsedWishlistBuild({
    List<Set<int>>? plugs,
    Set<WishlistTag>? tags,
    this.hash,
    this.name,
    this.description,
    this.originalWishlist,
  })  : this.plugs = plugs ?? <Set<int>>[],
        this.tags = tags ?? Set<WishlistTag>();

  factory ParsedWishlistBuild.fromJson(dynamic json) {
    return _$ParsedWishlistBuildFromJson(json);
  }

  dynamic toJson() {
    return _$ParsedWishlistBuildToJson(this);
  }
}

@JsonSerializable()
class ParsedWishlistItem {
  int itemHash;
  List<ParsedWishlistBuild> builds;
  Map<int, Set<WishlistTag>> perks;

  ParsedWishlistItem({
    required this.itemHash,
    List<ParsedWishlistBuild>? builds,
    Map<int, Set<WishlistTag>>? perks,
  })  : this.builds = builds ?? [],
        this.perks = perks ?? {};

  factory ParsedWishlistItem.fromJson(dynamic json) {
    return _$ParsedWishlistItemFromJson(json);
  }

  dynamic toJson() {
    return _$ParsedWishlistItemToJson(this);
  }
}
