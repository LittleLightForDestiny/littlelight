import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
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
    if (widget.onUpdate != null) widget.onUpdate();
    if (mounted) setState(() {});
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
          // Container(height: 8),
          // HeaderWidget(
          //     padding: EdgeInsets.all(0),
          //     alignment: Alignment.centerLeft,
          //     child: Container(
          //         padding: EdgeInsets.all(8),
          //         child: TranslatedTextWidget("Item Tags",
          //             uppercase: true,
          //             style: TextStyle(fontWeight: FontWeight.bold)))),
          // Container(height: 8),
          // buildTags(context),
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

  Widget buildTags(BuildContext context) {
    return Wrap(
      children: [
        tagButton(
            context,
            TranslatedTextWidget(
              "Add Tag",
              uppercase: true,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            leading: Icon(Icons.add_circle, size: 16)),
      ],
    );
  }

  Widget tagButton(BuildContext context, Widget label,
      {Widget leading, Widget trailing, Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)
          .copyWith(left: leading != null ? 8 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color ?? Theme.of(context).buttonColor,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        leading != null
            ? Container(padding: EdgeInsets.only(right: 4), child: leading)
            : Container(),
        label,
        trailing != null
            ? Container(padding: EdgeInsets.only(left: 8), child: trailing)
            : Container(),
      ]),
    );
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
          return Dialog(
            insetPadding: EdgeInsets.all(8),
            child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.all(8).copyWith(bottom: 4),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  HeaderWidget(
                      child: TranslatedTextWidget(
                    'Set nickname',
                    uppercase: true,
                  )),
                  TextField(
                    autofocus: true,
                    controller: _textFieldController,
                  ),
                  Container(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: RaisedButton(
                              visualDensity: VisualDensity.comfortable,
                              child: TranslatedTextWidget("Cancel",
                                  uppercase: true,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              })),
                      Container(
                        width: 4,
                      ),
                      Container(width: 4),
                      Expanded(
                          child: RaisedButton(
                              visualDensity: VisualDensity.comfortable,
                              child: TranslatedTextWidget("Save",
                                  uppercase: true,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(_textFieldController.text);
                              })),
                    ],
                  )
                ])),
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
          return Dialog(
            insetPadding: EdgeInsets.all(8),
            child: Container(
                constraints: BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.all(8).copyWith(bottom: 4),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  HeaderWidget(
                      child: TranslatedTextWidget(
                    'Set item notes',
                    uppercase: true,
                  )),
                  TextField(
                    autofocus: true,
                    controller: _textFieldController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                  ),
                  Container(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: RaisedButton(
                              visualDensity: VisualDensity.comfortable,
                              child: TranslatedTextWidget("Cancel",
                                  uppercase: true,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context).pop();
                              })),
                      Container(
                        width: 4,
                      ),
                      Container(width: 4),
                      Expanded(
                          child: RaisedButton(
                              visualDensity: VisualDensity.comfortable,
                              child: TranslatedTextWidget("Save",
                                  uppercase: true,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(_textFieldController.text);
                              })),
                    ],
                  )
                ])),
          );
        });

    if (result != null) {
      notes.notes = result;
      save();
    }
  }
}
