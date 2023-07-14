import 'package:get_it/get_it.dart';
import '../../core/blocs/littlelight_data/littlelight_data.bloc.dart';

LittleLightDataBloc getInjectedLittleLightDataService() => GetIt.I<LittleLightDataBloc>();

extension LittleLightDataServiceProvider on LittleLightDataConsumer {
  LittleLightDataBloc get littleLightData => getInjectedLittleLightDataService();
}

mixin LittleLightDataConsumer {}
