// @dart=2.9

import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/dialogs/set_item_nickname.dialog.dart';
import 'package:little_light/widgets/dialogs/set_item_notes.dialog.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';

class ItemDetailsNotesWidget extends BaseDestinyStatefulItemWidget {
  final Function onUpdate;
  ItemDetailsNotesWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
      this.onUpdate,
      String characterId})
      : super(item: item, definition: definition, instanceInfo: instanceInfo, key: key, characterId: characterId);

  @override
  ItemDetailsNotesWidgetState createState() {
    return ItemDetailsNotesWidgetState();
  }
}

const _sectionId = "item_tag_notes";

class ItemDetailsNotesWidgetState extends BaseDestinyItemState<ItemDetailsNotesWidget>
    with VisibleSectionMixin, ItemNotesConsumer {
  ItemNotes notes;

  @override
  String get sectionId => _sectionId;

  @override
  void initState() {
    super.initState();
    notes = itemNotes.getNotesForItem(item.itemHash, item.itemInstanceId, true);
    setState(() {});
  }

  String get customName {
    if ((notes?.customName?.length ?? 0) > 0) {
      return notes.customName;
    }
    return null;
  }

  String get notesText {
    if ((notes?.notes?.length ?? 0) > 0) {
      return notes.notes;
    }
    return null;
  }

  save() async {
    itemNotes.saveNotes(notes);
    if (mounted) setState(() {});
    if (widget.onUpdate != null) widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(children: <Widget>[
          getHeader(Text("Item Notes".translate(context).toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold))),
          visible ? Container(height: 8) : Container(),
          visible ? buildCustomName(context) : Container(),
          visible ? Container(height: 8) : Container(),
          visible ? buildNotes(context) : Container(),
        ]));
  }

  Widget buildCustomName(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text("Nickname".translate(context)),
      Container(width: 8),
      Expanded(
        child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.black54,
            child: customName != null ? Text(customName) : Text("Not set".translate(context))),
      ),
      Container(width: 8),
      iconButton(
        Icons.edit,
        onPressed: () {
          openEditNameDialog(context);
        },
      ),
      customName != null ? Container(width: 8) : Container(),
      customName != null
          ? iconButton(
              Icons.delete,
              color: Colors.red,
              onPressed: () async {
                notes.customName = null;
                save();
              },
            )
          : Container(),
    ]);
  }

  Widget buildNotes(BuildContext context) {
    return IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(
          child: Container(
              key: Key(notesText),
              padding: EdgeInsets.all(8),
              color: Colors.black54,
              child: notesText != null ? Text(notesText) : Text("No notes added yet".translate(context)))),
      Container(
        width: 8,
      ),
      Column(children: [
        iconButton(
          Icons.edit,
          onPressed: () {
            openEditNotesDialog(context);
          },
        ),
        itemNotes != null ? Container(height: 8) : Container(),
        itemNotes != null
            ? iconButton(
                Icons.delete,
                color: LittleLightTheme.of(context).errorLayers.layer0,
                onPressed: () {
                  notes.notes = null;
                  save();
                },
              )
            : Container(),
      ])
    ]));
  }

  iconButton(IconData icon, {Color color, Function onPressed}) {
    if (color == null) {
      color = LittleLightTheme.of(context).primaryLayers;
    }
    return Material(
        color: color,
        child: InkWell(
          child: Container(padding: EdgeInsets.all(4), child: CenterIconWorkaround(icon, size: 22)),
          onTap: onPressed,
        ));
  }

  openEditNameDialog(BuildContext context) async {
    final nickname = await Navigator.of(context).push(SetItemNicknameDialogRoute(context, notes.customName));
    if (nickname != null) {
      notes.customName = nickname;
      save();
    }
  }

  openEditNotesDialog(BuildContext context) async {
    final updatedNotes = await Navigator.of(context).push(SetItemNotesDialogRoute(context, notes.notes));
    if (updatedNotes != null) {
      notes.notes = updatedNotes;
      save();
    }
  }
}
