import 'package:bungie_api/models/destiny_item_component.dart';

class ItemWithOwner {
  final DestinyItemComponent item;
  final String ownerId;
  ItemWithOwner(this.item, this.ownerId);
}