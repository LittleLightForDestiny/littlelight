import 'package:flutter/material.dart';
import 'package:little_light/services/translate/translate.service.dart';


class LanguageButton extends RaisedButton {
  final String language;
  final bool selected;
  final TranslateService translate = new TranslateService();

  LanguageButton({this.language, this.selected = false, onPressed, color})
      : super(onPressed: onPressed, color: color);

  @override
  Widget get child {
    if (translate.languageNames[language] != null) {
      return Text(translate.languageNames[language].toUpperCase());
    }
    String languageName = language.split('-').join('\n');
    return Text(languageName);
  }

  @override
  double get elevation => 0;

  @override
  EdgeInsetsGeometry get padding =>
      EdgeInsets.symmetric(horizontal: 8, vertical: 8);
}
