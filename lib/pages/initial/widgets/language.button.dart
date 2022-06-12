import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/language_info.dart';

class LanguageButton extends StatelessWidget {
  final LanguageInfo language;
  final bool selected;
  final Function onPressed;

  LanguageButton({required this.language, this.selected = false, required this.onPressed}) : super();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          primary: selected ? LittleLightTheme.of(context).primaryLayers : Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.all(8)),
      child: _child,
      onPressed: () {
        this.onPressed();
      },
    );
  }

  Widget get _child {
    return Text(language.name.toUpperCase());
  }
}
