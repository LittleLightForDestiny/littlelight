import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
enum WishlistTag {
  PVP,
  PVE,
}

@JsonSerializable()
class WishListBuild {
  String identifier;
  Set<int> perks = Set();
  Set<WishlistTag> tags = Set();
  Set<String> notes = Set();
  WishListBuild({this.identifier, this.perks, this.tags, this.notes});

  factory WishListBuild.builder({
    String identifier,
    Set<int> perks,
    Set<WishlistTag> specialties,
    Set<String> notes,
  }) {
    return WishListBuild(
      identifier: identifier,
      perks: perks ?? Set(),
      tags: specialties ?? Set(),
      notes: notes ?? Set()
    );
  }
}

@JsonSerializable()
class WishList {
  int itemHash;
  Map<int, Set<WishlistTag>> perks = Map();
  Map<String, WishListBuild> builds = Map();
  WishList({this.itemHash, this.builds, this.perks});

  factory WishList.builder({
    int itemHash,
    Map<int, Set<WishlistTag>> perks,
    Map<String, WishListBuild> builds,
  }) {
    return WishList(
        itemHash: itemHash, perks: perks ?? Map(), builds: builds ?? Map());
  }
}
