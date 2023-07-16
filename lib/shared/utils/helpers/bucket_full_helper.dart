import 'package:bungie_api/destiny2.dart';

const bucketAlmostFullPercentage = .95;
bool isBucketAlmostFull(int? itemsInBucket, DestinyInventoryBucketDefinition? bucketDefinition) {
  final maximum = bucketDefinition?.itemCount;
  if (itemsInBucket == null || maximum == null) return false;
  final limit = maximum * bucketAlmostFullPercentage;
  return itemsInBucket > limit.floor();
}
