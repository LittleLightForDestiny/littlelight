import 'package:json_annotation/json_annotation.dart';

part 'd2_clarity_stat_state.g.dart';

@JsonSerializable()
class ClarityStatState {
  List<int>? stat;
  List<double>? multiplier;
  ClarityStatState({
    this.stat,
    this.multiplier,
  });

  factory ClarityStatState.fromJson(Map<String, dynamic> json) => _$ClarityStatStateFromJson(json);
  Map<String, dynamic> toJson() => _$ClarityStatStateToJson(this);
}
