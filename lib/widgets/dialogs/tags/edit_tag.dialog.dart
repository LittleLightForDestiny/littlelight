//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

import 'create_tag_form.widget.dart';

class EditTagDialogRoute extends DialogRoute<ItemNotesTag?> {
  EditTagDialogRoute(BuildContext context, ItemNotesTag? tag)
      : super(
          context: context,
          builder: (context) => EditTagDialog(),
          settings: RouteSettings(arguments: tag?.clone()),
        );
}

extension on BuildContext {
  ItemNotesTag? get tagArgument {
    final argument = ModalRoute.of(this)?.settings.arguments;
    if (argument is ItemNotesTag) {
      return argument;
    }
    return null;
  }
}

class EditTagDialog extends LittleLightBaseDialog {
  final newTag = ItemNotesTag.newCustom();
  EditTagDialog()
      : super(
          titleBuilder: (context) =>
              context.tagArgument != null ? TranslatedTextWidget('Select Tag') : TranslatedTextWidget('Create Tag'),
        );

  @override
  Widget? buildBody(BuildContext context) {
    return CreateTagFormWidget(context.tagArgument ?? this.newTag);
  }

  @override
  Widget? buildActions(BuildContext context) {
    final tag = context.tagArgument ?? this.newTag;
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
            Navigator.of(context).pop(tag);
          },
        ),
      ],
    );
  }
}
