// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'd2_clarity_stat_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClarityStatState _$ClarityStatStateFromJson(Map<String, dynamic> json) =>
    ClarityStatState(
      stat: (json['stat'] as List<dynamic>?)?.map((e) => e as int).toList(),
      multiplier: (json['multiplier'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$ClarityStatStateToJson(ClarityStatState instance) =>
    <String, dynamic>{
      'stat': instance.stat,
      'multiplier': instance.multiplier,
    };
