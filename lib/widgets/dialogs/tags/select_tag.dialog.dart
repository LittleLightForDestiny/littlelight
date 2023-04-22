import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/item_notes/item_notes.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';
import 'package:little_light/widgets/dialogs/tags/edit_tag.dialog.dart';
import 'package:little_light/shared/widgets/ui/center_icon_workaround.dart';
import 'package:little_light/shared/widgets/tags/tag_pill.widget.dart';
import 'package:provider/provider.dart';

import 'confirm_delete_tag.dialog.dart';

class SelectTagDialogRoute extends DialogRoute<ItemNotesTag?> {
  SelectTagDialogRoute(BuildContext context)
      : super(
          context: context,
          builder: (context) => SelectTagDialog(),
        );
}

class SelectTagDialog extends LittleLightBaseDialog {
  SelectTagDialog()
      : super(
            titleBuilder: (context) => TranslatedTextWidget('Select Tag'),
            bodyBuilder: (context) => const TagListWidget());

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(
            "Cancel".translate(context).toUpperCase(),
          ),
          onPressed: () async {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: Text(
            "Create tag".translate(context).toUpperCase(),
          ),
          onPressed: () async {
            final newTag = await Navigator.of(context).push(
              EditTagDialogRoute(
                context,
                ItemNotesTag.newCustom(),
              ),
            );
            final itemNotes = context.read<ItemNotesBloc>();
            if (newTag != null) {
              itemNotes.saveTag(newTag);
            }
          },
        ),
      ],
    );
  }
}

class TagListWidget extends StatelessWidget {
  const TagListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<ItemNotesBloc>().availableTags;
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: tags.map((t) => buildTag(context, t)).toList(),
    ));
  }

  Widget buildTag(BuildContext context, ItemNotesTag tag) => Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
            child: TagPillWidget.fromTag(
          tag,
          onTap: () => Navigator.of(context).pop(tag),
        )),
        if (tag.custom) buildTagOptions(context, tag)
      ]));

  Widget buildTagOptions(BuildContext context, ItemNotesTag tag) => Container(
      padding: const EdgeInsets.only(left: 8),
      child: Row(children: [
        iconButton(
          Icons.edit,
          LittleLightTheme.of(context).primaryLayers,
          () async {
            final edited = await Navigator.of(context).push(EditTagDialogRoute(context, tag));
            final itemNotes = context.read<ItemNotesBloc>();
            if (edited != null) {
              itemNotes.saveTag(edited);
            }
          },
        ),
        Container(
          width: 4,
        ),
        iconButton(
          Icons.delete,
          LittleLightTheme.of(context).errorLayers,
          () async {
            final confirmed = await Navigator.of(context).push(ConfirmDeleteTagDialogRoute(context, tag));
            final itemNotes = context.read<ItemNotesBloc>();
            if (confirmed ?? false) {
              itemNotes.deleteTag(tag);
            }
          },
        )
      ]));

  Widget iconButton(IconData icon, Color color, void Function()? onClick) {
    return Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
            onTap: onClick,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: CenterIconWorkaround(icon, size: 16),
            )));
  }
}
