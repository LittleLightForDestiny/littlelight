// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'parsed_wishlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParsedWishlist _$ParsedWishlistFromJson(Map<String, dynamic> json) => ParsedWishlist(
      (json['items'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), ParsedWishlistItem.fromJson(e)),
      ),
    );

Map<String, dynamic> _$ParsedWishlistToJson(ParsedWishlist instance) => <String, dynamic>{
      'items': instance.items.map((k, e) => MapEntry(k.toString(), e)),
    };

ParsedWishlistBuild _$ParsedWishlistBuildFromJson(Map<String, dynamic> json) => ParsedWishlistBuild(
      plugs: _jsonPlugsFromJson(json['plugs'] as List),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$WishlistTagEnumMap, e, unknownValue: WishlistTag.UnknownEnumValue))
          .toSet(),
      hash: json['hash'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      originalWishlist: json['originalWishlist'] as String?,
    );

Map<String, dynamic> _$ParsedWishlistBuildToJson(ParsedWishlistBuild instance) => <String, dynamic>{
      'hash': instance.hash,
      'name': instance.name,
      'plugs': instance.plugs.map((e) => e.toList()).toList(),
      'tags': instance.tags.map((e) => _$WishlistTagEnumMap[e]).toList(),
      'description': instance.description,
      'originalWishlist': instance.originalWishlist,
    };

const _$WishlistTagEnumMap = {
  WishlistTag.GodPVE: 'GodPVE',
  WishlistTag.GodPVP: 'GodPVP',
  WishlistTag.PVE: 'PVE',
  WishlistTag.PVP: 'PVP',
  WishlistTag.Bungie: 'Bungie',
  WishlistTag.Trash: 'Trash',
  WishlistTag.Mouse: 'Mouse',
  WishlistTag.Controller: 'Controller',
  WishlistTag.UnknownEnumValue: 'UnknownEnumValue',
};

ParsedWishlistItem _$ParsedWishlistItemFromJson(Map<String, dynamic> json) => ParsedWishlistItem(
      itemHash: json['itemHash'] as int,
      builds: (json['builds'] as List<dynamic>?)?.map((e) => ParsedWishlistBuild.fromJson(e)).toList(),
      perks: (json['perks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), (e as List<dynamic>).map((e) => $enumDecode(_$WishlistTagEnumMap, e)).toSet()),
      ),
    );

Map<String, dynamic> _$ParsedWishlistItemToJson(ParsedWishlistItem instance) => <String, dynamic>{
      'itemHash': instance.itemHash,
      'builds': instance.builds,
      'perks': instance.perks.map((k, e) => MapEntry(k.toString(), e.map((e) => _$WishlistTagEnumMap[e]).toList())),
    };
