//@dart=2.12
import 'package:bungie_api/destiny2.dart';
import 'package:little_light/services/notification/events/notification_type.dart';

class NotificationEvent {
  final NotificationType type;
  final DestinyItemComponent? item;
  final String? characterId;
  NotificationEvent(this.type, {this.item, this.characterId});
  
}