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
      return Image.asset("assets/imgs/flags/$language.png");
    }
    String languageName = language.split('-').join('\n');
    return AspectRatio(
      child: Container(
        decoration: BoxDecoration(
          color:Colors.blueGrey.shade300,
          shape: BoxShape.circle
        ),
        alignment: Alignment.center,
        child: Text(languageName.toUpperCase(),
        textAlign: TextAlign.center,),
      ),
      aspectRatio: 1,
    );
  }

  @override
  double get elevation => 0;

  @override
  EdgeInsetsGeometry get padding =>
      EdgeInsets.symmetric(horizontal: 8, vertical: 8);
}
