import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemDetailsNotesWidget extends BaseDestinyStatefulItemWidget {
  ItemDetailsNotesWidget(
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      Key key,
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child:Column(children: <Widget>[
      HeaderWidget(
          padding: EdgeInsets.all(0),
           alignment: Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.all(8),
              child: TranslatedTextWidget("Item notes",
                  uppercase: true,
                  style: TextStyle(fontWeight: FontWeight.bold)))),
      Container(height: 8),
      buildCustomName(context),
      buildNotesField(context)
    ]));
  }

  Widget buildCustomName(BuildContext context) {
    return RaisedButton(
      child: TranslatedTextWidget("Add custom name"),
      onPressed: () {},
    );
  }

  Widget buildNotesField(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.multiline,
      maxLines: 4,
    );
  }
}
