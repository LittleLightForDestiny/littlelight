//@dart=2.12
import 'package:get_it/get_it.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'language.service.dart';

LanguageService getInjectedLanguageService() => GetIt.I<LanguageService>();

mixin LanguageConsumer {
  LanguageService get languageService => getInjectedLanguageService();
}
