import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/littlelight_custom.dialog.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemDetailsNotesWidget extends BaseDestinyStatefulItemWidget {
  final Function onUpdate;
  ItemDetailsNotesWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
      this.onUpdate,
      String characterId})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key,
            characterId: characterId);

  @override
  ItemDetailsNotesWidgetState createState() {
    return ItemDetailsNotesWidgetState();
  }
}

class ItemDetailsNotesWidgetState
    extends BaseDestinyItemState<ItemDetailsNotesWidget> {
  ItemNotes notes;

  @override
  void initState() {
    super.initState();
    notes =
        ItemNotesService().getNotesForItem(item.itemHash, item.itemInstanceId);
    setState(() {});
  }

  String get customName {
    if ((notes?.customName?.length ?? 0) > 0) {
      return notes.customName;
    }
    return null;
  }

  String get itemNotes {
    if ((notes?.notes?.length ?? 0) > 0) {
      return notes.notes;
    }
    return null;
  }

  save() async {
    await ItemNotesService().saveNotes(notes);
    if (mounted) setState(() {});
    if (widget.onUpdate != null) widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(children: <Widget>[
          HeaderWidget(
              padding: EdgeInsets.all(0),
              alignment: Alignment.centerLeft,
              child: Container(
                  padding: EdgeInsets.all(8),
                  child: TranslatedTextWidget("Item Notes",
                      uppercase: true,
                      style: TextStyle(fontWeight: FontWeight.bold)))),
          Container(height: 8),
          buildCustomName(context),
          Container(height: 8),
          buildNotes(context),
        ]));
  }

  Widget buildCustomName(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      TranslatedTextWidget("Nickname"),
      Container(width: 8),
      Expanded(
        child: Container(
            padding: EdgeInsets.all(8),
            color: Colors.black54,
            child: customName != null
                ? Text(customName)
                : TranslatedTextWidget("Not set")),
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
              key: Key(itemNotes),
              padding: EdgeInsets.all(8),
              color: Colors.black54,
              child: itemNotes != null
                  ? Text(itemNotes)
                  : TranslatedTextWidget("No notes added yet"))),
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
                color: Colors.red,
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
      color = Theme.of(context).buttonColor;
    }
    return Material(
        color: color,
        child: InkWell(
          child: Container(
              padding: EdgeInsets.all(4), child: Icon(icon, size: 22)),
          onTap: onPressed,
        ));
  }

  openEditNameDialog(BuildContext context) async {
    TextEditingController _textFieldController =
        TextEditingController(text: customName);
    var result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return LittleLightCustomDialog.withSaveCancelButtons(
            TextField(
              autofocus: true,
              controller: _textFieldController,
            ),
            title: TranslatedTextWidget(
              'Set nickname',
              uppercase: true,
            ),
            onCancel: () => Navigator.of(context).pop(),
            onSave: () => Navigator.of(context).pop(_textFieldController.text),
          );
        });
    if (result != null) {
      notes.customName = result;
      save();
    }
  }

  openEditNotesDialog(BuildContext context) async {
    TextEditingController _textFieldController =
        TextEditingController(text: notes.notes ?? "");
    var result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return LittleLightCustomDialog.withSaveCancelButtons(
              TextField(
                autofocus: true,
                controller: _textFieldController,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
              ),
              title: TranslatedTextWidget(
                'Set item notes',
                uppercase: true,
              ),
              onCancel: () => Navigator.of(context).pop(),
              onSave: () =>
                  Navigator.of(context).pop(_textFieldController.text));
        });

    if (result != null) {
      notes.notes = result;
      save();
    }
  }
}
