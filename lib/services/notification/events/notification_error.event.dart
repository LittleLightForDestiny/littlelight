import 'package:bungie_api/destiny2.dart';

import 'notification.event.dart';

enum ErrorNotificationType {
  genericTransferError,
  genericEquipError,
  onCombatZoneEquipError,
  genericApplyModError,
  onCombatZoneApplyModError,
  genericUpdateError
}

class ErrorNotificationEvent extends NotificationEvent {
  final ErrorNotificationType errorType;

  ErrorNotificationEvent(this.errorType, {DestinyItemComponent? item, String? characterId})
      : super(null, item: item, characterId: characterId);
}
