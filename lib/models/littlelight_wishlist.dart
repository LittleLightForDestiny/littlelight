import 'package:json_annotation/json_annotation.dart';

part 'littlelight_wishlist.g.dart';

@JsonSerializable()
class LittleLightWishlist {
  String name;
  String description;
  List<LittleLightWishlistItem> data;

  Map<String, String> versionRedirects;

  LittleLightWishlist(
      {this.name, this.description, this.data, this.versionRedirects});

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
  String originalWishlist;
  LittleLightWishlistItem(
      {this.name,
      this.description,
      this.plugs,
      this.hash,
      this.tags,
      this.authors,
      this.originalWishlist});

  factory LittleLightWishlistItem.fromJson(dynamic json) {
    return _$LittleLightWishlistItemFromJson(json);
  }

  dynamic toJson() {
    return _$LittleLightWishlistItemToJson(this);
  }
}
