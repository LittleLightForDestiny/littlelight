// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=2.12

part of 'tracked_objective.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackedObjective _$TrackedObjectiveFromJson(Map<String, dynamic> json) {
  return TrackedObjective(
    type: _$enumDecode(_$TrackedObjectiveTypeEnumMap, json['type']),
    hash: json['hash'] as int?,
    instanceId: json['instanceId'] as String?,
    characterId: json['characterId'] as String?,
    parentHash: json['parentHash'] as int?,
  );
}

Map<String, dynamic> _$TrackedObjectiveToJson(TrackedObjective instance) =>
    <String, dynamic>{
      'type': _$TrackedObjectiveTypeEnumMap[instance.type],
      'hash': instance.hash,
      'instanceId': instance.instanceId,
      'characterId': instance.characterId,
      'parentHash': instance.parentHash,
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

const _$TrackedObjectiveTypeEnumMap = {
  TrackedObjectiveType.Triumph: 'triumph',
  TrackedObjectiveType.Item: 'item',
  TrackedObjectiveType.Plug: 'plug',
};
