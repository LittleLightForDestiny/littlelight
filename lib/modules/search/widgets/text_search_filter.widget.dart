import 'package:flutter/material.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';

typedef OnTextUpdate = void Function(String query);

class TextSearchFilterWidget extends StatefulWidget {
  final bool forceAutoFocus;
  final OnTextUpdate? onUpdate;
  const TextSearchFilterWidget({this.forceAutoFocus = false, this.onUpdate}) : super();

  @override
  _TextSearchFilterWidgetState createState() => _TextSearchFilterWidgetState();
}

class _TextSearchFilterWidgetState extends State<TextSearchFilterWidget> with UserSettingsConsumer {
  final TextEditingController _searchFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchFieldController.addListener(updateText);
  }

  @override
  void dispose() {
    _searchFieldController.removeListener(updateText);
    super.dispose();
  }

  void updateText() {
    widget.onUpdate?.call(_searchFieldController.text);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // decoration: const InputDecoration(isDense: true),
      autofocus: userSettings.autoOpenKeyboard || widget.forceAutoFocus,
      controller: _searchFieldController,
    );
  }
}
