// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReputationRanks _$ReputationRanksFromJson(Map<String, dynamic> json) =>
    ReputationRanks(
      glory: json['glory'] as int,
      valor: json['valor'] as int,
      infamy: json['infamy'] as int,
    );

Map<String, dynamic> _$ReputationRanksToJson(ReputationRanks instance) =>
    <String, dynamic>{
      'glory': instance.glory,
      'valor': instance.valor,
      'infamy': instance.infamy,
    };

GameData _$GameDataFromJson(Map<String, dynamic> json) => GameData(
      softCap: json['softCap'] as int,
      powerfulCap: json['powerfulCap'] as int,
      pinnacleCap: json['pinnacleCap'] as int,
      relevantCurrencies: (json['relevantCurrencies'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      raidPhases: (json['raidPhases'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      cosmeticSocketCategories:
          (json['cosmeticSocketCategories'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList(),
      craftingSocketCategories:
          (json['craftingSocketCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      deepsightSocketCategories:
          (json['deepsightSocketCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
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
    };
