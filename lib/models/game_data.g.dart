// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) {
  return GameData(
    softCap: json['softCap'] as int,
    powerfulCap: json['powerfulCap'] as int,
    pinnacleCap: json['pinnacleCap'] as int,
    seasonalModSlots:
        (json['seasonalModSlots'] as List)?.map((e) => e as int)?.toList(),
  );
}

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'softCap': instance.softCap,
      'powerfulCap': instance.powerfulCap,
      'pinnacleCap': instance.pinnacleCap,
      'seasonalModSlots': instance.seasonalModSlots,
    };
