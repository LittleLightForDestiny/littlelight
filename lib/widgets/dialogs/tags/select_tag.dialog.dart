import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';
import 'package:little_light/widgets/dialogs/tags/edit_tag.dialog.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';
import 'package:little_light/widgets/item_tags/item_tag.widget.dart';
import 'package:provider/provider.dart';

import 'confirm_delete_tag.dialog.dart';

class TagsChangedNotifier extends ChangeNotifier with ItemNotesConsumer {
  List<ItemNotesTag> get tags => itemNotes.getAvailableTags();
  void changed() {
    notifyListeners();
  }
}

class SelectTagDialogRoute extends DialogRoute<ItemNotesTag?> {
  SelectTagDialogRoute(BuildContext context)
      : super(
          context: context,
          builder: (context) => ChangeNotifierProvider<TagsChangedNotifier>(
            create: (context) => TagsChangedNotifier(),
            child: SelectTagDialog(),
          ),
        );
}

class SelectTagDialog extends LittleLightBaseDialog with ItemNotesConsumer {
  SelectTagDialog()
      : super(titleBuilder: (context) => TranslatedTextWidget('Select Tag'), bodyBuilder: (context) => TagListWidget());

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
          child: TranslatedTextWidget("Create tag", uppercase: true),
          onPressed: () async {
            final newTag = await Navigator.of(context).push(
              EditTagDialogRoute(
                context,
                ItemNotesTag.newCustom(),
              ),
            );
            if (newTag != null) {
              itemNotes.saveTag(newTag);
            }
            context.read<TagsChangedNotifier>().changed();
          },
        ),
      ],
    );
  }
}

class TagListWidget extends StatelessWidget with ItemNotesConsumer {
  const TagListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tags = context.watch<TagsChangedNotifier>().tags;
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: tags.map((t) => buildTag(context, t)).toList(),
    ));
  }

  Widget buildTag(BuildContext context, ItemNotesTag tag) => Container(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Expanded(
            child: ItemTagWidget(
          tag,
          includeLabel: true,
          padding: 4,
          onClick: () {
            Navigator.of(context).pop(tag);
          },
        )),
        if (tag.custom) buildTagOptions(context, tag)
      ]));

  Widget buildTagOptions(BuildContext context, ItemNotesTag tag) => Container(
      padding: EdgeInsets.only(left: 8),
      child: Row(children: [
        iconButton(
          Icons.edit,
          LittleLightTheme.of(context).primaryLayers,
          () async {
            final edited = await Navigator.of(context).push(EditTagDialogRoute(context, tag));
            if (edited != null) {
              itemNotes.saveTag(edited);
            }
            context.read<TagsChangedNotifier>().changed();
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
            if (confirmed ?? false) {
              itemNotes.deleteTag(tag);
            }
            context.read<TagsChangedNotifier>().changed();
          },
        )
      ]));

  Widget iconButton(IconData icon, Color color, void onClick()?) {
    return Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
            onTap: onClick,
            child: Container(
              padding: EdgeInsets.all(4),
              child: CenterIconWorkaround(icon, size: 16),
            )));
  }
}
