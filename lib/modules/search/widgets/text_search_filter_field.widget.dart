import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:provider/provider.dart';

typedef OnTextUpdate = void Function(String query);

class TextSearchFilterFieldWidget extends StatefulWidget {
  final bool forceAutoFocus;
  final OnTextUpdate? onUpdate;
  final Duration debounce;
  final String? hintText;
  const TextSearchFilterFieldWidget({
    this.forceAutoFocus = false,
    this.onUpdate,
    this.debounce = const Duration(milliseconds: 200),
    this.hintText,
  }) : super();

  @override
  _TextSearchFilterFieldWidgetState createState() => _TextSearchFilterFieldWidgetState();
}

class _TextSearchFilterFieldWidgetState extends State<TextSearchFilterFieldWidget> {
  Timer? _debouncer;

  void updateText(String text) {
    if (_debouncer?.isActive ?? false) _debouncer?.cancel();
    _debouncer = Timer(widget.debounce, () {
      widget.onUpdate?.call(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSettings = context.watch<UserSettingsBloc>();
    return TextField(
      autofocus: userSettings.autoOpenKeyboard || widget.forceAutoFocus,
      onChanged: (text) => updateText(text),
      decoration: InputDecoration(hintText: widget.hintText),
    );
  }
}
