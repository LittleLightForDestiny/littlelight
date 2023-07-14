// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loadout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Loadout _$LoadoutFromJson(Map<String, dynamic> json) => Loadout(
      assignedId: json['assignedId'] as String?,
      name: json['name'] as String? ?? "",
      emblemHash: json['emblemHash'] as int?,
      equipped: (json['equipped'] as List<dynamic>?)
              ?.map(LoadoutItem.fromJson)
              .toList() ??
          const [],
      unequipped: (json['unequipped'] as List<dynamic>?)
              ?.map(LoadoutItem.fromJson)
              .toList() ??
          const [],
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LoadoutToJson(Loadout instance) => <String, dynamic>{
      'assignedId': instance.assignedId,
      'name': instance.name,
      'emblemHash': instance.emblemHash,
      'equipped': instance.equipped,
      'unequipped': instance.unequipped,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

LoadoutItem _$LoadoutItemFromJson(Map<String, dynamic> json) => LoadoutItem(
      itemInstanceId: json['itemInstanceId'] as String?,
      itemHash: json['itemHash'] as int?,
      socketPlugs: (json['socketPlugs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), e as int),
      ),
      bucketHash: json['bucketHash'] as int?,
      classType: $enumDecodeNullable(_$DestinyClassEnumMap, json['classType']),
    );

Map<String, dynamic> _$LoadoutItemToJson(LoadoutItem instance) =>
    <String, dynamic>{
      'itemInstanceId': instance.itemInstanceId,
      'itemHash': instance.itemHash,
      'socketPlugs':
          instance.socketPlugs?.map((k, e) => MapEntry(k.toString(), e)),
      'bucketHash': instance.bucketHash,
      'classType': _$DestinyClassEnumMap[instance.classType],
    };

const _$DestinyClassEnumMap = {
  DestinyClass.Titan: 0,
  DestinyClass.Hunter: 1,
  DestinyClass.Warlock: 2,
  DestinyClass.Unknown: 3,
  DestinyClass.ProtectedInvalidEnumValue: 999999999,
};
