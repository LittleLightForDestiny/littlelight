import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_stat.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_description.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_item_type.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_stat_types.dart';

part 'd2_clarity_item.g.dart';

DateTime? _dateFromJson(int int) => DateTime.fromMillisecondsSinceEpoch(int);
int? _dateToJson(DateTime? time) => time?.millisecondsSinceEpoch;

@JsonSerializable()
class ClarityItem {
  int? hash;
  int? itemHash;

  String? name;
  String? itemName;

  ClarityItemType? type;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime? lastUpload;
  String? uploadedBy;

  Map<String, List<ClarityDescription>>? descriptions;
  Map<ClarityStatType, List<ClarityStat>>? stats;

  ClarityItem({
    this.hash,
    this.itemHash,
    this.name,
    this.itemName,
    this.lastUpload,
    this.type,
    this.uploadedBy,
    this.descriptions,
    this.stats,
  });

  factory ClarityItem.fromJson(Map<String, dynamic> json) => _$ClarityItemFromJson(json);
  Map<String, dynamic> toJson() => _$ClarityItemToJson(this);
}
