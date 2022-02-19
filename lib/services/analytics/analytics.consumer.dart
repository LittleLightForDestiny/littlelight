//@dart=2.12
import 'package:little_light/services/setup.dart';

import 'analytics.service.dart';

AnalyticsService getInjectedAnalyticsService() => getItCoreInstance<AnalyticsService>();

extension AnalyticsConumerExtension on AnalyticsConsumer {
  AnalyticsService get analytics => getInjectedAnalyticsService();
}

mixin AnalyticsConsumer {}
