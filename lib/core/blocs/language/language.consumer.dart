import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'language.bloc.dart';

LanguageBloc getInjectedLanguageService() => GetIt.I<LanguageBloc>();

extension LanguageContextConsumer on BuildContext {
  String get currentLanguage => this.watch<LanguageBloc>().currentLanguage;

  String translate(
    String text, {
    String? languageCode,
    Map<String, String> replace = const {},
    bool useReadContext = false,
  }) =>
      useReadContext
          ? this.read<LanguageBloc>().translate(text, languageCode: languageCode, replace: replace)
          : this.watch<LanguageBloc>().translate(text, languageCode: languageCode, replace: replace);
}

extension TranslateString on String {
  String translate(
    BuildContext context, {
    String? languageCode,
    Map<String, String> replace = const {},
    bool useReadContext = false,
  }) =>
      context.translate(
        this,
        languageCode: languageCode,
        replace: replace,
        useReadContext: useReadContext,
      );
}
