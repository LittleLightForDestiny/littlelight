//@dart=2.12
import 'package:bungie_api/destiny2.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';

class ItemWithOwner {
  static const OWNER_VAULT = "vault";
  static const OWNER_PROFILE = "profile";
  final DestinyItemComponent? item;
  final String? _ownerId;
  String get ownerId {
    if (_ownerId != null) {
      return _ownerId!;
    }
    if (item?.bucketHash == InventoryBucket.general) return OWNER_VAULT;
    return OWNER_PROFILE;
  }

  ItemWithOwner(this.item, this._ownerId);
}
