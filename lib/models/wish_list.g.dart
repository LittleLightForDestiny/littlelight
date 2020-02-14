// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wish_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistBuild _$WishlistBuildFromJson(Map<String, dynamic> json) {
  return WishlistBuild(
    identifier: json['identifier'] as String,
    perks: (json['perks'] as List)?.map((e) => e as int)?.toSet(),
    tags: (json['tags'] as List)
        ?.map((e) => _$enumDecodeNullable(_$WishlistTagEnumMap, e))
        ?.toSet(),
    notes: (json['notes'] as List)?.map((e) => e as String)?.toSet(),
  );
}

Map<String, dynamic> _$WishlistBuildToJson(WishlistBuild instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'perks': instance.perks?.toList(),
      'tags': instance.tags?.map((e) => _$WishlistTagEnumMap[e])?.toList(),
      'notes': instance.notes?.toList(),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$WishlistTagEnumMap = {
  WishlistTag.PVP: 'PVP',
  WishlistTag.PVE: 'PVE',
  WishlistTag.Bungie: 'Bungie',
  WishlistTag.Trash: 'Trash',
};

WishlistItem _$WishlistItemFromJson(Map<String, dynamic> json) {
  return WishlistItem(
    itemHash: json['itemHash'] as int,
    builds: (json['builds'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e == null ? null : WishlistBuild.fromJson(e)),
    ),
    perks: (json['perks'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          int.parse(k),
          (e as List)
              ?.map((e) => _$enumDecodeNullable(_$WishlistTagEnumMap, e))
              ?.toSet()),
    ),
  );
}

Map<String, dynamic> _$WishlistItemToJson(WishlistItem instance) =>
    <String, dynamic>{
      'itemHash': instance.itemHash,
      'perks': instance.perks?.map((k, e) => MapEntry(
          k.toString(), e?.map((e) => _$WishlistTagEnumMap[e])?.toList())),
      'builds': instance.builds,
    };

Wishlist _$WishlistFromJson(Map<String, dynamic> json) {
  return Wishlist(
    url: json['url'] as String,
    localFilename: json['localFilename'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    type: _$enumDecodeNullable(_$WishlistTypeEnumMap, json['type']),
    isDefault: json['isDefault'] as bool ?? true,
  );
}

Map<String, dynamic> _$WishlistToJson(Wishlist instance) => <String, dynamic>{
      'url': instance.url,
      'localFilename': instance.localFilename,
      'name': instance.name,
      'description': instance.description,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'type': _$WishlistTypeEnumMap[instance.type],
      'isDefault': instance.isDefault,
    };

const _$WishlistTypeEnumMap = {
  WishlistType.DimWishlist: 'DimWishlist',
};
