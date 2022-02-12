//@dart=2.12
import 'package:get_it/get_it.dart';

import 'notification.service.dart';

extension NotificationConsumerExtension on NotificationConsumer {
  NotificationService get notifications => GetIt.I<NotificationService>();
}

mixin NotificationConsumer {}
