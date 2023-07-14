import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/models/loadout.dart';
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
          titleBuilder: (context) => Text("Delete loadout".translate(context)),
          bodyBuilder: (context) => Text(
            "Do you really want to delete the loadout {loadoutName} ?"
                .translate(context, replace: {"loadoutName": context.loadoutArgument?.name ?? ""}),
          ),
        );
}
