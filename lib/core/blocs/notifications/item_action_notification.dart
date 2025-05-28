import 'package:little_light/core/blocs/notifications/action_notification.dart';
import 'package:little_light/models/item_info/destiny_item_info.dart';

abstract class ItemActionNotification extends ActionNotification {
  final DestinyItemInfo item;

  @override
  int? get targetHash => item.itemHash;

  ItemActionNotification({required this.item});
}
