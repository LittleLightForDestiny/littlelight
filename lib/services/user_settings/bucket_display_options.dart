//@dart=2.12
import 'package:json_annotation/json_annotation.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

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


const defaultBucketDisplayOptions = {
  "${InventoryBucket.engrams}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.lostItems}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.consumables}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.shaders}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "${InventoryBucket.modifications}":
      BucketDisplayOptions(type: BucketDisplayType.Small),
  "pursuits_53_null": BucketDisplayOptions(type: BucketDisplayType.Large),
};