import 'package:get_it/get_it.dart';

import 'language.service.dart';

LanguageService getInjectedLanguageService()=>GetIt.I<LanguageService>();

mixin LanguageConsumer {
  LanguageService get languageService => getInjectedLanguageService();
}