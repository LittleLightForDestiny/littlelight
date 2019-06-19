import 'package:json_annotation/json_annotation.dart';

part 'character_sort_parameter.g.dart';

enum CharacterSortParameterType {
  LastPlayed,
  FirstCreated,
  LastCreated,
  Custom,
}

@JsonSerializable()
class CharacterSortParameter {
  CharacterSortParameterType type;
  List<String> customOrder;

  CharacterSortParameter(
      {this.type = CharacterSortParameterType.LastPlayed, this.customOrder});

  static CharacterSortParameter fromJson(dynamic json) {
    return _$CharacterSortParameterFromJson(json);
  }

  dynamic toJson() {
    return _$CharacterSortParameterToJson(this);
  }
}
