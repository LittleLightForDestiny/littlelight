//@dart=2.12
import 'package:json_annotation/json_annotation.dart';

part 'littlelight_wishlist.g.dart';

@JsonSerializable()
class LittleLightWishlist {
  String? name;
  String? description;
  List<LittleLightWishlistBuild> data;

  Map<String, String>? versionRedirects;

  LittleLightWishlist({this.name, this.description, required this.data, this.versionRedirects});

  factory LittleLightWishlist.fromJson(dynamic json) {
    return _$LittleLightWishlistFromJson(json);
  }

  dynamic toJson() {
    return _$LittleLightWishlistToJson(this);
  }
}

@JsonSerializable()
class LittleLightWishlistBuild {
  String? name;
  String? description;
  List<List<int>> plugs;
  int hash;
  List<String> tags;
  List<String>? authors;
  String? originalWishlist;
  LittleLightWishlistBuild(
      {this.name,
      this.description,
      required this.plugs,
      required this.hash,
      required this.tags,
      this.authors,
      this.originalWishlist});

  factory LittleLightWishlistBuild.fromJson(dynamic json) {
    return _$LittleLightWishlistBuildFromJson(json);
  }

  dynamic toJson() {
    return _$LittleLightWishlistBuildToJson(this);
  }
}
