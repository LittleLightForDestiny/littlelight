import 'package:json_annotation/json_annotation.dart';

part 'game_data.g.dart';

@JsonSerializable()
class GameData {
  int softCap;
  int powerfulCap;
  int pinnacleCap;
  List<int> seasonalModSlots;
  List<int> tabbedPresentationNodes;

  GameData(
      {this.softCap,
      this.powerfulCap,
      this.pinnacleCap,
      this.seasonalModSlots,
      this.tabbedPresentationNodes});

  factory GameData.fromJson(dynamic json) {
    return _$GameDataFromJson(json);
  }

  dynamic toJson() {
    return _$GameDataToJson(this);
  }
}
