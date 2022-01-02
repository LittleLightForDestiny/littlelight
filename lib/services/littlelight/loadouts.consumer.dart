//@dart=2.12
import 'package:get_it/get_it.dart';
import 'loadouts.service.dart';



LoadoutsService getInjectedLoadoutsService()=>GetIt.I<LoadoutsService>();

extension LoadoutsServiceProvider on LoadoutsConsumer{
  LoadoutsService get loadoutService => getInjectedLoadoutsService();
}
mixin LoadoutsConsumer {
}