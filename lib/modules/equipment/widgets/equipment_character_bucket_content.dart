import 'package:little_light/models/item_info/destiny_item_info.dart';

class EquipmentCharacterBucketContent {
  final int bucketHash;
  final DestinyItemInfo? equipped;
  final List<DestinyItemInfo> unequipped;

  EquipmentCharacterBucketContent(
    this.bucketHash, {
    required this.equipped,
    required this.unequipped,
  });
}
