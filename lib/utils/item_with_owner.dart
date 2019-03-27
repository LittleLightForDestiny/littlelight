import 'package:bungie_api/models/destiny_item_component.dart';

class ItemWithOwner {
  DestinyItemComponent item;
  String ownerId;
  ItemWithOwner(this.item, this.ownerId);
}