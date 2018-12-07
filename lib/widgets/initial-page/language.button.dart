import 'package:flutter/material.dart';
class LanguageButton extends StatelessWidget {
  final String language;
  final bool selected;
  final Function onPressed;
  LanguageButton({this.language, this.selected = false, @required this.onPressed});

  @override
  Widget build(BuildContext context) {   
    return new FractionallySizedBox(
      widthFactor: .25,
      child:FlatButton(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        onPressed: this.onPressed,
        color: selected ? Theme.of(context).buttonColor : Colors.transparent,
        child: new Image.asset(
          "assets/imgs/flags/$language.png"
          ),
      )
    );
    
  }
}
