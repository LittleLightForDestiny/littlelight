import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_class_names.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_formula.dart';

import 'd2_clarity_description.dart';

part 'd2_clarity_table_cell.g.dart';

@JsonSerializable()
class ClarityTableCell {
  String? text;
  List<ClarityDescription>? title;

  @JsonKey(unknownEnumValue: ClarityFormulaType.Unknown)
  ClarityFormulaType? formula;

  @JsonKey(unknownEnumValue: ClarityClassNames.Unknown)
  List<ClarityClassNames>? classNames;

  ClarityTableCell({
    this.text,
    this.classNames,
  });

  factory ClarityTableCell.fromJson(Map<String, dynamic> json) => _$ClarityTableCellFromJson(json);
  dynamic toJson() => _$ClarityTableCellToJson(this);
}
