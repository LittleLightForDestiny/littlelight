import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/littlelight_custom.dialog.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';
import 'package:little_light/widgets/item_tags/create_tag_form.widget.dart';
import 'package:little_light/widgets/item_tags/item_tag.widget.dart';

class ItemDetailsTagsWidget extends BaseDestinyStatefulItemWidget {
  final Function onUpdate;
  ItemDetailsTagsWidget(
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
  ItemDetailsTagsWidgetState createState() {
    return ItemDetailsTagsWidgetState();
  }
}

class ItemDetailsTagsWidgetState
    extends BaseDestinyItemState<ItemDetailsTagsWidget> {
  ItemNotes notes;
  List<ItemNotesTag> tags;

  @override
  void initState() {
    super.initState();
    notes = ItemNotesService()
        .getNotesForItem(item?.itemHash, item?.itemInstanceId, true);
    tags = ItemNotesService().tagsByIds(notes?.tags);
    setState(() {});
  }

  save() async {
    ItemNotesService().saveNotes(notes);
    if (widget.onUpdate != null) widget.onUpdate();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (tags == null) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              HeaderWidget(
                  padding: EdgeInsets.all(0),
                  alignment: Alignment.centerLeft,
                  child: Container(
                      padding: EdgeInsets.all(8),
                      child: TranslatedTextWidget("Item Tags",
                          uppercase: true,
                          style: TextStyle(fontWeight: FontWeight.bold)))),
              Container(height: 8),
              buildTags(context),
            ]));
  }

  Widget buildTags(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: 4,
      spacing: 4,
      children: tags
          .map((t) => ItemTagWidget(
                t,
                includeLabel: true,
                padding: 4,
                trailing: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    child: CenterIconWorkaround(
                        FontAwesomeIcons.solidTimesCircle,
                        size: 16,
                        color: Colors.red)),
                onClick: () {
                  notes.tags.remove(t.tagId);
                  save();
                },
              ))
          ?.followedBy([
        ItemTagWidget(
            ItemNotesTag(
                icon: null, name: "Add Tag", backgroundColorHex: "#03A9f4"),
            includeLabel: true,
            padding: 4,
            trailing:
                CenterIconWorkaround(FontAwesomeIcons.plusCircle, size: 18),
            onClick: () => openAddTagDialog(context)),
      ]).toList(),
    );
  }

  openAddTagDialog(BuildContext context) async {
    var tags = ItemNotesService().getAvailableTags();
    var result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return LittleLightCustomDialog.withHorizontalButtons(
              SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: tags
                    .map((t) => Container(
                        margin: EdgeInsets.only(top: 8),
                        child: (t?.custom ?? false)
                            ? Row(children: [
                                Expanded(
                                    child: ItemTagWidget(
                                  t,
                                  includeLabel: true,
                                  padding: 4,
                                  onClick: () {
                                    Navigator.of(context).pop(t.tagId);
                                  },
                                )),
                                Container(
                                  width: 8,
                                ),
                                iconButton(
                                  Icons.edit,
                                  Colors.lightBlue.shade500,
                                  () async {
                                    Navigator.of(context).pop();
                                    openEditTagDialog(context, t);
                                  },
                                ),
                                Container(
                                  width: 4,
                                ),
                                iconButton(
                                  Icons.delete,
                                  Colors.red,
                                  () async {
                                    Navigator.of(context).pop();
                                    confirmDelete(context, t);
                                  },
                                ),
                              ])
                            : ItemTagWidget(
                                t,
                                includeLabel: true,
                                padding: 4,
                                onClick: () {
                                  Navigator.of(context).pop(t.tagId);
                                },
                              )))
                    .toList(),
              )),
              maxWidth: 400,
              buttons: [
                RaisedButton(
                    visualDensity: VisualDensity.comfortable,
                    child: TranslatedTextWidget("Cancel",
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                RaisedButton(
                    visualDensity: VisualDensity.comfortable,
                    child: TranslatedTextWidget("Create tag",
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      openCreateTagDialog(context);
                    })
              ],
              title: TranslatedTextWidget(
                'Select tag',
                uppercase: true,
              ));
        });

    if (result != null) {
      notes.tags.add(result);
      save();
    }
  }

  openCreateTagDialog(BuildContext context) async {
    var tag = ItemNotesTag.newCustom();
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return LittleLightCustomDialog.withSaveCancelButtons(
            CreateTagFormWidget(tag),
            title: TranslatedTextWidget(
              'Create tag',
              uppercase: true,
            ),
            onSave: () async {
              ItemNotesService().saveTag(tag);
              Navigator.of(context).pop(tag.tagId);
              openAddTagDialog(context);
            },
            onCancel: () {
              Navigator.of(context).pop();
              openAddTagDialog(context);
            },
          );
        });
  }

  openEditTagDialog(BuildContext context, ItemNotesTag tag) async {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return LittleLightCustomDialog.withSaveCancelButtons(
            CreateTagFormWidget(tag),
            title: TranslatedTextWidget(
              'Edit tag',
              uppercase: true,
            ),
            onSave: () async {
              ItemNotesService().saveTag(tag);
              Navigator.of(context).pop(tag.tagId);
              save();
              openAddTagDialog(context);
            },
            onCancel: () {
              Navigator.of(context).pop();
              openAddTagDialog(context);
            },
          );
        });
  }

  Widget iconButton(IconData icon, Color color, Function onClick) {
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

  Future<void> confirmDelete(BuildContext context, ItemNotesTag tag) async {
    await showDialog<bool>(
        context: context,
        builder: (context) => LittleLightCustomDialog.withYesNoButtons(
              Container(
                  padding: EdgeInsets.all(8).copyWith(top: 16),
                  child: TranslatedTextWidget(
                      "Do you really want to delete the tag {tagName} ?",
                      style: TextStyle(fontSize: 16),
                      replace: {"tagName": tag.name})),
              maxWidth: 300,
              title: TranslatedTextWidget(
                "Delete tag",
                uppercase: true,
              ),
              yesPressed: () {
                ItemNotesService().deleteTag(tag);
                Navigator.of(context).pop();
                openAddTagDialog(context);
                save();
              },
              noPressed: () {
                Navigator.of(context).pop();
                openAddTagDialog(context);
              },
            ));
  }
}
