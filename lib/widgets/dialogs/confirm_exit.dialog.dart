import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.yes_no.dialog.dart';

class ConfirmExitDialogRoute extends DialogRoute<bool> {
  ConfirmExitDialogRoute(BuildContext context)
      : super(
          context: context,
          builder: (context) => ConfirmExitDialog(),
        );
}

class ConfirmExitDialog extends LittleLightYesNoDialog {
  ConfirmExitDialog()
      : super(
          titleBuilder: (context) => TranslatedTextWidget('Exit'),
          bodyBuilder: (context) =>
              TranslatedTextWidget('Do you really want to exit Little Light?'),
        );
}
