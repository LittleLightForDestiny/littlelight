import 'package:little_light/services/setup.dart';
import 'analytics.service.dart';

AnalyticsService? getInjectedAnalyticsService() {
  final gi = getItCoreInstance;
  if (gi == null) return null;
  final isRegistered = gi.isRegistered<AnalyticsService>();
  if (!isRegistered) return null;
  return gi.get<AnalyticsService>();
}

extension AnalyticsConumerExtension on AnalyticsConsumer {
  AnalyticsService? get analytics => getInjectedAnalyticsService();
}

mixin AnalyticsConsumer {}
