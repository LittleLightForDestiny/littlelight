import 'package:little_light/core/blocs/notifications/base_notification_action.dart';
import 'package:little_light/shared/utils/helpers/loadout_helpers.dart';

class LoadoutChangeResultNotification extends BasePersistentNotification {
  LoadoutChangeResults results;

  LoadoutChangeResultNotification(LoadoutChangeResults this.results);

  @override
  String get id => 'loadout-change-result-notification';
}
