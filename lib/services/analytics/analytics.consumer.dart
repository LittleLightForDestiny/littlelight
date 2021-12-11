//@dart=2.12
import 'package:get_it/get_it.dart';
import 'analytics.service.dart';

AnalyticsService getInjectedAnalyticsService() => GetIt.I<AnalyticsService>();

mixin AnalyticsConsumer {
    AnalyticsService get analytics => getInjectedAnalyticsService();
}