import 'package:json_annotation/json_annotation.dart';

part 'game_data.g.dart';

@JsonSerializable()
class GameData {
  int softCap;
  int powerfulCap;
  int pinnacleCap;

  GameData({
    this.softCap,
    this.powerfulCap,
    this.pinnacleCap,
  });

  factory GameData.fromJson(dynamic json) {
    return _$GameDataFromJson(json);
  }

  dynamic toJson() {
    return _$GameDataToJson(this);
  }
}