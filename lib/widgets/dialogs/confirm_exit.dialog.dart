import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
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
          titleBuilder: (context) => Text("Exit".translate(context)),
          bodyBuilder: (context) => Text("Do you really want to exit Little Light?".translate(context)),
        );
}
