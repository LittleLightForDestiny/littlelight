import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';

typedef OnTextUpdate = void Function(String query);

class TextSearchFilterFieldWidget extends StatefulWidget {
  final bool forceAutoFocus;
  final OnTextUpdate? onUpdate;
  final Duration debounce;
  const TextSearchFilterFieldWidget(
      {this.forceAutoFocus = false,
      this.onUpdate,
      this.debounce = const Duration(milliseconds: 500)})
      : super();

  @override
  _TextSearchFilterFieldWidgetState createState() =>
      _TextSearchFilterFieldWidgetState();
}

class _TextSearchFilterFieldWidgetState
    extends State<TextSearchFilterFieldWidget> with UserSettingsConsumer {
  Timer? _debouncer;

  void updateText(String text) {
    if (_debouncer?.isActive ?? false) _debouncer?.cancel();
    _debouncer = Timer(widget.debounce, () {
      widget.onUpdate?.call(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: userSettings.autoOpenKeyboard || widget.forceAutoFocus,
      onChanged: (text) => updateText(text),
    );
  }
}
