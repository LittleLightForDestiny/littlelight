//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

class SetItemNotesDialogRoute extends DialogRoute<String?> {
  SetItemNotesDialogRoute(BuildContext context, String currentNotes)
      : super(
          context: context,
          builder: (context) => SetItemNotesDialog(context.notesArgument ?? ""),
          settings: RouteSettings(arguments: currentNotes),
        );
}

extension on BuildContext {
  String? get notesArgument {
    final argument = ModalRoute.of(this)?.settings.arguments;
    if (argument is String) {
      return argument;
    }
    return null;
  }
}

class SetItemNotesDialog extends LittleLightBaseDialog {
  final TextEditingController _controller;
  SetItemNotesDialog(String initialValue)
      : _controller = TextEditingController(text: initialValue),
        super(
          titleBuilder: (context) => TranslatedTextWidget('Set item notes'),
        );

  @override
  Widget? buildBody(BuildContext context) {
    return TextField(
      autofocus: true,
      controller: _controller,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
    );
  }

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: TranslatedTextWidget("Cancel", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: TranslatedTextWidget("Save", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop(_controller.value.text);
          },
        ),
      ],
    );
  }
}
