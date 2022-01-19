import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/item_notes.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/tags/select_tag.dialog.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';
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

const _sectionId = "item_tags";

class ItemDetailsTagsWidgetState
    extends BaseDestinyItemState<ItemDetailsTagsWidget>
    with VisibleSectionMixin, ItemNotesConsumer {
  ItemNotes notes;
  List<ItemNotesTag> tags;

  @override
  String get sectionId => _sectionId;

  @override
  void initState() {
    super.initState();
    notes = itemNotes
        .getNotesForItem(item?.itemHash, item?.itemInstanceId, true);
    tags = itemNotes.tagsByIds(notes?.tags);
    setState(() {});
  }

  save() async {
    tags = itemNotes.tagsByIds(notes?.tags);
    itemNotes.saveNotes(notes);
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
              getHeader(TranslatedTextWidget("Item Tags",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold))),
              visible ? Container(height: 8) : Container(),
              visible ? buildTags(context) : Container(),
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
                        color: Theme.of(context).colorScheme.onSurface),
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
          .followedBy([
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

  void openAddTagDialog(BuildContext context) async {
    final tag = await Navigator.of(context).push(SelectTagDialogRoute(context));
    if (tag != null) {
      notes.tags.add(tag.tagId);
      save();
    }
  }
}
