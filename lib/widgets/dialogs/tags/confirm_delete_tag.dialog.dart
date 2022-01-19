//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.yes_no.dialog.dart';

class ConfirmDeleteTagDialogRoute extends DialogRoute<bool> {
  ConfirmDeleteTagDialogRoute(BuildContext context, ItemNotesTag tag)
      : super(
            context: context, builder: (context) => ConfirmDeleteTagDialog(), settings: RouteSettings(arguments: tag));
}

class ConfirmDeleteTagDialog extends LittleLightYesNoDialog {
  ConfirmDeleteTagDialog()
      : super(
            titleBuilder: (context) => TranslatedTextWidget('Select Tag'),
            bodyBuilder: (context) {
              final tag = ModalRoute.of(context)?.settings.arguments as ItemNotesTag;
              return TranslatedTextWidget("Do you really want to delete the tag {tagName} ?",
                  replace: {"tagName": tag.name});
            });
}
