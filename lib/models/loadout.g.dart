// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'loadout.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Loadout _$LoadoutFromJson(Map<String, dynamic> json) {
  return Loadout(
    assignedId: json['assignedId'] as String?,
    name: json['name'] as String,
    emblemHash: json['emblemHash'] as int?,
    equipped: (json['equipped'] as List<dynamic>)
        .map((e) => LoadoutItem.fromJson(e))
        .toList(),
    unequipped: (json['unequipped'] as List<dynamic>)
        .map((e) => LoadoutItem.fromJson(e))
        .toList(),
    updatedAt: json['updated_at'] == null
        ? null
        : DateTime.parse(json['updated_at'] as String),
  );
}

Map<String, dynamic> _$LoadoutToJson(Loadout instance) => <String, dynamic>{
      'assignedId': instance.assignedId,
      'name': instance.name,
      'emblemHash': instance.emblemHash,
      'equipped': instance.equipped,
      'unequipped': instance.unequipped,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

LoadoutItem _$LoadoutItemFromJson(Map<String, dynamic> json) {
  return LoadoutItem(
    itemInstanceId: json['itemInstanceId'] as String?,
    itemHash: json['itemHash'] as int?,
  );
}

Map<String, dynamic> _$LoadoutItemToJson(LoadoutItem instance) =>
    <String, dynamic>{
      'itemInstanceId': instance.itemInstanceId,
      'itemHash': instance.itemHash,
    };
