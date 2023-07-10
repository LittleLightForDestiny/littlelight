import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/language_info.dart';

class LanguageButton extends StatelessWidget {
  final LanguageInfo language;
  final bool selected;
  final Function onPressed;

  const LanguageButton({required this.language, this.selected = false, required this.onPressed}) : super();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: selected ? LittleLightTheme.of(context).primaryLayers : Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.all(8)),
      child: _child,
      onPressed: () {
        onPressed();
      },
    );
  }

  Widget get _child {
    return Text(language.name.toUpperCase());
  }
}
