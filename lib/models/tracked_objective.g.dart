// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_objective.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackedObjective _$TrackedObjectiveFromJson(Map<String, dynamic> json) {
  return TrackedObjective(
      type: _$enumDecodeNullable(_$TrackedObjectiveTypeEnumMap, json['type']),
      hash: json['hash'] as int,
      instanceId: json['instanceId'] as String,
      characterId: json['characterId'] as String,
      parentHash: json['parentHash'] as int);
}

Map<String, dynamic> _$TrackedObjectiveToJson(TrackedObjective instance) =>
    <String, dynamic>{
      'type': _$TrackedObjectiveTypeEnumMap[instance.type],
      'hash': instance.hash,
      'instanceId': instance.instanceId,
      'characterId': instance.characterId,
      'parentHash': instance.parentHash
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$TrackedObjectiveTypeEnumMap = <TrackedObjectiveType, dynamic>{
  TrackedObjectiveType.Triumph: 'triumph',
  TrackedObjectiveType.Item: 'item',
  TrackedObjectiveType.Plug: 'plug'
};
