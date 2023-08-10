import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_class_names.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_formula.dart';

import 'd2_clarity_description.dart';

part 'd2_clarity_line_content.g.dart';

@JsonSerializable()
class ClarityLineContent {
  List<ClarityDescription>? title;
  String? text;
  ClarityFormulaType? formula;
  String? link;

  @JsonKey(unknownEnumValue: ClarityClassNames.Unknown)
  List<ClarityClassNames>? classNames;

  ClarityLineContent({
    this.title,
    this.text,
    this.classNames,
    this.formula,
    this.link,
  });

  factory ClarityLineContent.fromJson(Map<String, dynamic> json) => _$ClarityLineContentFromJson(json);
  dynamic toJson() => _$ClarityLineContentToJson(this);
}
