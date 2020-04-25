import 'package:json_annotation/json_annotation.dart';

part 'game_data.g.dart';

@JsonSerializable()
class GameData {
  int softCap;
  int powerfulCap;
  int pinnacleCap;
  List<int> seasonalModSlots;

  GameData({
    this.softCap,
    this.powerfulCap,
    this.pinnacleCap,
    this.seasonalModSlots
  });

  factory GameData.fromJson(dynamic json) {
    return _$GameDataFromJson(json);
  }

  dynamic toJson() {
    return _$GameDataToJson(this);
  }
}