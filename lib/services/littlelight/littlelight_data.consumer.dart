import 'package:get_it/get_it.dart';
import 'littlelight_data.service.dart';

LittleLightDataService getInjectedLittleLightDataService() =>
    GetIt.I<LittleLightDataService>();

extension LittleLightDataServiceProvider on LittleLightDataConsumer {
  LittleLightDataService get littleLightData =>
      getInjectedLittleLightDataService();
}

mixin LittleLightDataConsumer {}
