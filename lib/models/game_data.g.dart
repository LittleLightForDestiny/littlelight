// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReputationRanks _$ReputationRanksFromJson(Map<String, dynamic> json) {
  return ReputationRanks(
    glory: json['glory'] as int,
    valor: json['valor'] as int,
    infamy: json['infamy'] as int,
  );
}

Map<String, dynamic> _$ReputationRanksToJson(ReputationRanks instance) =>
    <String, dynamic>{
      'glory': instance.glory,
      'valor': instance.valor,
      'infamy': instance.infamy,
    };

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return GameData(
    softCap: json['softCap'] as int,
    powerfulCap: json['powerfulCap'] as int,
    pinnacleCap: json['pinnacleCap'] as int,
    seasonalModSlots:
        (json['seasonalModSlots'] as List)?.map((e) => e as int)?.toList(),
    tabbedPresentationNodes: (json['tabbedPresentationNodes'] as List)
        ?.map((e) => e as int)
        ?.toList(),
    ranks:
        json['ranks'] == null ? null : ReputationRanks.fromJson(json['ranks']),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'softCap': instance.softCap,
      'powerfulCap': instance.powerfulCap,
      'pinnacleCap': instance.pinnacleCap,
      'seasonalModSlots': instance.seasonalModSlots,
      'tabbedPresentationNodes': instance.tabbedPresentationNodes,
      'ranks': instance.ranks,
    };
