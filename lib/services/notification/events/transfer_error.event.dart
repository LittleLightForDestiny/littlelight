import 'package:bungie_api/destiny2.dart';
import 'package:little_light/services/inventory/enums/transfer_error_type.dart';

import 'notification.event.dart';
import 'notification_type.dart';

class TransferErrorEvent extends NotificationEvent {
  final TransferErrorType code;
  TransferErrorEvent(NotificationType type,
      {DestinyItemComponent item, String characterId, this.code})
      : super(type, item: item, characterId: characterId);
}