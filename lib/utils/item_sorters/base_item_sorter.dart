import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

abstract class BaseItemSorter {
  int direction;
  BaseItemSorter(this.direction);

  DestinyItemInstanceComponent instance(ItemWithOwner item) =>
      ProfileService().getInstanceInfo(item?.item?.itemInstanceId);
  DestinyInventoryItemDefinition def(ItemWithOwner item) =>
      ManifestService().getDefinitionFromCache<DestinyInventoryItemDefinition>(
          item?.item?.itemHash);

  int sort(ItemWithOwner a, ItemWithOwner b);
}
