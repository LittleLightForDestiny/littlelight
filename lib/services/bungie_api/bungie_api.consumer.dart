//@dart=2.12

import 'package:get_it/get_it.dart';
import 'bungie_api.service.dart';


getInjectedBungieApi() => GetIt.I<BungieApiService>();

extension BungieApiServiceProvider on BungieApiConsumer{
  BungieApiService get bungieAPI => getInjectedBungieApi();
}

class BungieApiConsumer {}
