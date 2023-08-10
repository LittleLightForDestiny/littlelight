import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_description_weapon_type.dart';

part 'd2_clarity_stat.g.dart';

@JsonSerializable()
class ClarityStat {
  dynamic active;
  dynamic passive;

  @JsonKey(unknownEnumValue: ClarityWeaponType.Unknown)
  List<ClarityWeaponType>? weaponTypes;

  ClarityStat({
    this.active,
    this.passive,
    this.weaponTypes,
  });

  factory ClarityStat.fromJson(Map<String, dynamic> json) => _$ClarityStatFromJson(json);
  Map<String, dynamic> toJson() => _$ClarityStatToJson(this);
}
