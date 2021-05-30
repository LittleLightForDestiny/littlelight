import 'package:json_annotation/json_annotation.dart';

part 'game_data.g.dart';

@JsonSerializable()
class ReputationRanks {
  int glory;
  int valor;
  int infamy;
  ReputationRanks({this.glory, this.valor, this.infamy});

  factory ReputationRanks.fromJson(dynamic json) {
    return _$ReputationRanksFromJson(json);
  }

  dynamic toJson() {
    return _$ReputationRanksToJson(this);
  }
}

@JsonSerializable()
class GameData {
  int softCap;
  int powerfulCap;
  int pinnacleCap;
  List<int> seasonalModSlots;
  List<int> tabbedPresentationNodes;
  ReputationRanks ranks;

  GameData(
      {this.softCap,
      this.powerfulCap,
      this.pinnacleCap,
      this.seasonalModSlots,
      this.tabbedPresentationNodes,
      this.ranks});

  factory GameData.fromJson(dynamic json) {
    return _$GameDataFromJson(json);
  }

  dynamic toJson() {
    return _$GameDataToJson(this);
  }
}
