import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'language.bloc.dart';

extension LanguageContextConsumer on BuildContext {
  String get currentLanguage => watch<LanguageBloc>().currentLanguage;

  String translate(
    String text, {
    String? languageCode,
    Map<String, String> replace = const {},
    bool useReadContext = false,
    String? overrideDefaultText,
  }) =>
      useReadContext
          ? read<LanguageBloc>()
              .translate(text, languageCode: languageCode, replace: replace, overrideDefaultText: overrideDefaultText)
          : watch<LanguageBloc>()
              .translate(text, languageCode: languageCode, replace: replace, overrideDefaultText: overrideDefaultText);
}

extension TranslateString on String {
  String translate(
    BuildContext context, {
    String? languageCode,
    Map<String, String> replace = const {},
    bool useReadContext = false,
    String? overrideDefaultText,
  }) =>
      context.translate(
        this,
        languageCode: languageCode,
        replace: replace,
        useReadContext: useReadContext,
        overrideDefaultText: overrideDefaultText,
      );
}
