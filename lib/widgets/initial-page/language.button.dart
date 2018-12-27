import 'package:flutter/material.dart';
class LanguageButton extends RaisedButton {
  final String language;
  final bool selected;
  
  LanguageButton({this.language, this.selected = false, onPressed, color}):super(onPressed:onPressed, color:color);

  

   @override  
  Widget get child => Image.asset(
    "assets/imgs/flags/$language.png"
  );

  @override
    double get elevation => 0;

  @override
    EdgeInsetsGeometry get padding => EdgeInsets.symmetric(horizontal: 8, vertical: 8);
}
