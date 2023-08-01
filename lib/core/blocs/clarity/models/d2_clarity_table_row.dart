import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_class_names.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_table_cell.dart';

part 'd2_clarity_table_row.g.dart';

@JsonSerializable()
class ClarityTableRow {
  List<ClarityClassNames>? classNames;
  List<ClarityTableCell>? rowContent;

  ClarityTableRow({
    this.classNames,
    this.rowContent,
  });

  factory ClarityTableRow.fromJson(Map<String, dynamic> json) => _$ClarityTableRowFromJson(json);
  dynamic toJson() => _$ClarityTableRowToJson(this);
}
