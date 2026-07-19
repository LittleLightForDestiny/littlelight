// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReputationRanks _$ReputationRanksFromJson(Map<String, dynamic> json) => ReputationRanks(
  glory: (json['glory'] as num).toInt(),
  valor: (json['valor'] as num).toInt(),
  infamy: (json['infamy'] as num).toInt(),
);

Map<String, dynamic> _$ReputationRanksToJson(ReputationRanks instance) => <String, dynamic>{
  'glory': instance.glory,
  'valor': instance.valor,
  'infamy': instance.infamy,
};

GameData _$GameDataFromJson(Map<String, dynamic> json) => GameData(
  softCap: (json['softCap'] as num).toInt(),
  powerfulCap: (json['powerfulCap'] as num).toInt(),
  pinnacleCap: (json['pinnacleCap'] as num).toInt(),
  relevantCurrencies: (json['relevantCurrencies'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList(),
  raidPhases: (json['raidPhases'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  cosmeticSocketCategories: (json['cosmeticSocketCategories'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  craftingSocketCategories: (json['craftingSocketCategories'] as List<dynamic>?)?.map((e) => e as String).toList(),
  deepsightSocketCategories: (json['deepsightSocketCategories'] as List<dynamic>?)?.map((e) => e as String).toList(),
  weaponsMissingBreakerType: _$JsonConverterFromJson<Map<String, dynamic>, Map<int, DestinyBreakerType>>(
    json['weaponsMissingBreakerType'],
    const BreakerMapConverter().fromJson,
  ),
);

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
  'softCap': instance.softCap,
  'powerfulCap': instance.powerfulCap,
  'pinnacleCap': instance.pinnacleCap,
  'relevantCurrencies': instance.relevantCurrencies,
  'raidPhases': instance.raidPhases,
  'cosmeticSocketCategories': instance.cosmeticSocketCategories,
  'craftingSocketCategories': instance.craftingSocketCategories,
  'deepsightSocketCategories': instance.deepsightSocketCategories,
  'weaponsMissingBreakerType': _$JsonConverterToJson<Map<String, dynamic>, Map<int, DestinyBreakerType>>(
    instance.weaponsMissingBreakerType,
    const BreakerMapConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
