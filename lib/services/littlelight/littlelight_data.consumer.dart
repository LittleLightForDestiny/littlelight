//@dart=2.12
import 'package:get_it/get_it.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/littlelight/littlelight_data.service.dart';


LittleLightDataService getInjectedLittleLightDataService()=>GetIt.I<LittleLightDataService>();

mixin LittleLightDataConsumer {
  LittleLightDataService get littleLightData => getInjectedLittleLightDataService();
}