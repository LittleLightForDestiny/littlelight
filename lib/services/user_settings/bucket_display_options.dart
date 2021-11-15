//@dart=2.12
import 'package:json_annotation/json_annotation.dart';

part 'bucket_display_options.g.dart';

enum BucketDisplayType {
  Hidden,
  OnlyEquipped,
  Large,
  Medium,
  Small,
}

@JsonSerializable()
class BucketDisplayOptions {
  final BucketDisplayType type;

  const BucketDisplayOptions({required this.type});

  static BucketDisplayOptions fromJson(dynamic json) {
    return _$BucketDisplayOptionsFromJson(json);
  }

  dynamic toJson() {
    return _$BucketDisplayOptionsToJson(this);
  }
}
