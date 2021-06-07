// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'littlelight_wishlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LittleLightWishlist _$LittleLightWishlistFromJson(Map<String, dynamic> json) {
  return LittleLightWishlist(
    name: json['name'] as String,
    description: json['description'] as String,
    data: (json['data'] as List)
        ?.map((e) => e == null ? null : LittleLightWishlistItem.fromJson(e))
        ?.toList(),
    versionRedirects: (json['versionRedirects'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    ),
  );
}

Map<String, dynamic> _$LittleLightWishlistToJson(
        LittleLightWishlist instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'data': instance.data,
      'versionRedirects': instance.versionRedirects,
    };

LittleLightWishlistItem _$LittleLightWishlistItemFromJson(
    Map<String, dynamic> json) {
  return LittleLightWishlistItem(
    name: json['name'] as String,
    description: json['description'] as String,
    plugs: (json['plugs'] as List)
        ?.map((e) => (e as List)?.map((e) => e as int)?.toList())
        ?.toList(),
    hash: json['hash'] as int,
    tags: (json['tags'] as List)?.map((e) => e as String)?.toList(),
    authors: (json['authors'] as List)?.map((e) => e as String)?.toList(),
    originalWishlist: json['originalWishlist'] as String,
  );
}

Map<String, dynamic> _$LittleLightWishlistItemToJson(
        LittleLightWishlistItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'plugs': instance.plugs,
      'hash': instance.hash,
      'tags': instance.tags,
      'authors': instance.authors,
      'originalWishlist': instance.originalWishlist,
    };
