// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracked_objective.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackedObjective _$TrackedObjectiveFromJson(Map<String, dynamic> json) =>
    TrackedObjective(
      type: $enumDecode(_$TrackedObjectiveTypeEnumMap, json['type']),
      hash: json['hash'] as int?,
      instanceId: json['instanceId'] as String?,
      characterId: json['characterId'] as String?,
      parentHash: json['parentHash'] as int?,
    );

Map<String, dynamic> _$TrackedObjectiveToJson(TrackedObjective instance) =>
    <String, dynamic>{
      'type': _$TrackedObjectiveTypeEnumMap[instance.type]!,
      'hash': instance.hash,
      'instanceId': instance.instanceId,
      'characterId': instance.characterId,
      'parentHash': instance.parentHash,
    };

const _$TrackedObjectiveTypeEnumMap = {
  TrackedObjectiveType.Triumph: 'triumph',
  TrackedObjectiveType.Item: 'item',
  TrackedObjectiveType.Plug: 'plug',
  TrackedObjectiveType.Questline: 'questline',
};
