//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.yes_no.dialog.dart';

extension on BuildContext {
  Loadout? get loadoutArgument {
    final argument = ModalRoute.of(this)?.settings.arguments;
    if (argument is Loadout) {
      return argument;
    }
    return null;
  }
}

class ConfirmDeleteLoadoutDialogRoute extends DialogRoute<bool> {
  ConfirmDeleteLoadoutDialogRoute(BuildContext context, Loadout loadout)
      : super(
            context: context,
            builder: (context) => ConfirmDeleteLoadoutDialog(),
            settings: RouteSettings(arguments: loadout));
}

class ConfirmDeleteLoadoutDialog extends LittleLightYesNoDialog {
  ConfirmDeleteLoadoutDialog()
      : super(
          titleBuilder: (context) => TranslatedTextWidget('Delete loadout'),
          bodyBuilder: (context) => TranslatedTextWidget(
            'Do you really want to delete the loadout {loadoutName} ?',
            replace: {"loadoutName": context.loadoutArgument?.name ?? ""},
          ),
        );
}
