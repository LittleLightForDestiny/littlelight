import 'package:flutter/material.dart';
import 'package:little_light/services/translate/translate.service.dart';

class LanguageButton extends StatelessWidget {
  final String language;
  final bool selected;
  final TranslateService translate = new TranslateService();
  final Function onPressed;

  LanguageButton({this.language, this.selected = false, this.onPressed})
      : super();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary:
              selected ? Theme.of(context).buttonColor : Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.all(8)),
      child: _child,
      onPressed: this.onPressed,
    );
  }

  Widget get _child {
    if (translate.languageNames[language] != null) {
      return Text(translate.languageNames[language].toUpperCase());
    }
    String languageName = language.split('-').join('\n');
    return Text(languageName);
  }
}
