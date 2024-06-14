import 'package:get_it/get_it.dart';
import 'bungie_api.service.dart';

BungieApiService getInjectedBungieApi() => GetIt.I<BungieApiService>();

extension BungieApiServiceProvider on BungieApiConsumer {
  @deprecated
  BungieApiService get bungieAPI => getInjectedBungieApi();
}

mixin BungieApiConsumer {}
