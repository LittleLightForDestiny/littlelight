// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'wish_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistBuild _$WishlistBuildFromJson(Map<String, dynamic> json) {
  return WishlistBuild(
    name: json['name'] as String?,
    perks: _jsonPlugsFromJson(json['perks'] as List),
    tags: (json['tags'] as List<dynamic>?)
        ?.map((e) => _$enumDecode(_$WishlistTagEnumMap, e,
            unknownValue: WishlistTag.UnknownEnumValue))
        .toSet(),
    notes: (json['notes'] as List<dynamic>?)?.map((e) => e as String).toSet(),
    originalWishlist: json['originalWishlist'] as String?,
  );
}

Map<String, dynamic> _$WishlistBuildToJson(WishlistBuild instance) =>
    <String, dynamic>{
      'name': instance.name,
      'perks': instance.perks.map((e) => e.toList()).toList(),
      'tags': instance.tags?.map((e) => _$WishlistTagEnumMap[e]).toList(),
      'notes': instance.notes?.toList(),
      'originalWishlist': instance.originalWishlist,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

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

WishlistItem _$WishlistItemFromJson(Map<String, dynamic> json) {
  return WishlistItem(
    itemHash: json['itemHash'] as int,
    builds: (json['builds'] as List<dynamic>)
        .map((e) => WishlistBuild.fromJson(e))
        .toList(),
    perks: (json['perks'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          int.parse(k),
          (e as List<dynamic>)
              .map((e) => _$enumDecode(_$WishlistTagEnumMap, e))
              .toSet()),
    ),
  );
}

Map<String, dynamic> _$WishlistItemToJson(WishlistItem instance) =>
    <String, dynamic>{
      'itemHash': instance.itemHash,
      'perks': instance.perks.map((k, e) => MapEntry(
          k.toString(), e.map((e) => _$WishlistTagEnumMap[e]).toList())),
      'builds': instance.builds,
    };

Wishlist _$WishlistFromJson(Map<String, dynamic> json) {
  return Wishlist(
    url: json['url'] as String?,
    localFilename: json['localFilename'] as String?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    type: _$enumDecodeNullable(_$WishlistTypeEnumMap, json['type']),
  );
}

Map<String, dynamic> _$WishlistToJson(Wishlist instance) => <String, dynamic>{
      'url': instance.url,
      'localFilename': instance.localFilename,
      'name': instance.name,
      'description': instance.description,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'type': _$WishlistTypeEnumMap[instance.type],
    };

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$WishlistTypeEnumMap = {
  WishlistType.DimWishlist: 'DimWishlist',
};
