// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'littlelight_wishlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LittleLightWishlist _$LittleLightWishlistFromJson(Map<String, dynamic> json) =>
    LittleLightWishlist(
      name: json['name'] as String?,
      description: json['description'] as String?,
      data: (json['data'] as List<dynamic>)
          .map(LittleLightWishlistBuild.fromJson)
          .toList(),
      versionRedirects:
          (json['versionRedirects'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$LittleLightWishlistToJson(
        LittleLightWishlist instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'data': instance.data,
      'versionRedirects': instance.versionRedirects,
    };

LittleLightWishlistBuild _$LittleLightWishlistBuildFromJson(
        Map<String, dynamic> json) =>
    LittleLightWishlistBuild(
      name: json['name'] as String?,
      description: json['description'] as String?,
      plugs: (json['plugs'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).map((e) => e as int).toList())
          .toList(),
      hash: json['hash'] as int,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      authors:
          (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      originalWishlist: json['originalWishlist'] as String?,
    );

Map<String, dynamic> _$LittleLightWishlistBuildToJson(
        LittleLightWishlistBuild instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'plugs': instance.plugs,
      'hash': instance.hash,
      'tags': instance.tags,
      'authors': instance.authors,
      'originalWishlist': instance.originalWishlist,
    };
