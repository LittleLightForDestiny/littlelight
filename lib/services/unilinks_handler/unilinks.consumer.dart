import 'package:little_light/services/setup.dart';
import 'package:little_light/services/unilinks_handler/unilinks_handler.dart';

UnilinksHandler? getInjectedUnilinksHandler() {
  if (!getItCoreInstance.isRegistered<UnilinksHandler>()) return null;
  return getItCoreInstance<UnilinksHandler>();
}

extension UnilinksConsumerExtension on UnilinksConsumer {
  UnilinksHandler? get unilinks => getInjectedUnilinksHandler();
}

mixin UnilinksConsumer {}
