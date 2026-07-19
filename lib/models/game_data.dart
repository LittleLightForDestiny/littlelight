import 'package:json_annotation/json_annotation.dart';
import 'package:bungie_api/enums/destiny_breaker_type.dart';

part 'game_data.g.dart';

@JsonSerializable()
class ReputationRanks {
  int glory;
  int valor;
  int infamy;
  ReputationRanks({
    required this.glory,
    required this.valor,
    required this.infamy,
  });

  factory ReputationRanks.fromJson(dynamic json) {
    return _$ReputationRanksFromJson(json);
  }

  dynamic toJson() {
    return _$ReputationRanksToJson(this);
  }
}

class BreakerMapConverter implements JsonConverter<Map<int, DestinyBreakerType>, Map<String, dynamic>> {
  const BreakerMapConverter();

  @override
  Map<int, DestinyBreakerType> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(
        int.parse(key),
        DestinyBreakerType.values[value as int],
      ),
    );
  }

  @override
  Map<String, int> toJson(Map<int, DestinyBreakerType> object) {
    return object.map(
      (key, value) => MapEntry(
        key.toString(),
        value.index,
      ),
    );
  }
}

@JsonSerializable()
class GameData {
  int softCap;
  int powerfulCap;
  int pinnacleCap;

  List<int>? relevantCurrencies;
  Map<String, String>? raidPhases;

  List<int>? cosmeticSocketCategories;
  List<String>? craftingSocketCategories;
  List<String>? deepsightSocketCategories;
  @BreakerMapConverter()
  Map<int, DestinyBreakerType>? weaponsMissingBreakerType;

  GameData({
    required this.softCap,
    required this.powerfulCap,
    required this.pinnacleCap,
    this.relevantCurrencies,
    this.raidPhases,
    this.cosmeticSocketCategories,
    this.craftingSocketCategories,
    this.deepsightSocketCategories,
    this.weaponsMissingBreakerType,
  });

  factory GameData.fromJson(dynamic json) {
    return _$GameDataFromJson(json);
  }

  dynamic toJson() {
    return _$GameDataToJson(this);
  }
}
