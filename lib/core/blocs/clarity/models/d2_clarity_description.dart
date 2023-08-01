import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_class_names.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_description_weapon_type.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_line_content.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_table_row.dart';

part 'd2_clarity_description.g.dart';

@JsonSerializable()
class ClarityDescription {
  List<ClarityLineContent>? linesContent;
  List<ClarityClassNames>? classNames;
  List<ClarityTableRow>? table;
  bool? isFormula;
  List<ClarityWeaponType>? weaponTypes;

  ClarityDescription({
    this.linesContent,
    this.classNames,
    this.table,
    this.isFormula,
    this.weaponTypes,
  });

  factory ClarityDescription.fromJson(dynamic json) => _$ClarityDescriptionFromJson(json);
  Map<String, dynamic> toJson() => _$ClarityDescriptionToJson(this);
}
