import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/edit_loadout.screen.dart';
import 'package:little_light/screens/equip_loadout.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class LoadoutListItemWidget extends StatefulWidget {
  final Map<String, LoadoutItemIndex> itemIndexes;
  final Loadout loadout;
  const LoadoutListItemWidget(this.loadout, {Key key, this.itemIndexes})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadoutListItemWidgetState();
  }
}

class LoadoutListItemWidgetState extends State<LoadoutListItemWidget> {
  LoadoutItemIndex _itemIndex;
  @override
  initState() {
    super.initState();
    if (itemIndex == null) {
      buildItemIndex();
    }
  }

  LoadoutItemIndex get itemIndex {
    return _itemIndex ?? widget.itemIndexes[widget.loadout.assignedId];
  }

  buildItemIndex() async {
    _itemIndex = await InventoryUtils.buildLoadoutItemIndex(widget.loadout);
    widget.itemIndexes[widget.loadout.assignedId] = _itemIndex;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(8),
        child: Material(
            elevation: 1,
            child: Column(children: [
              Container(
                height: kToolbarHeight,
                color: Theme.of(context).primaryColor,
                child: buildTitleBar(context),
              ),
              buildItemRows(context),
              buildButtonBar(context)
            ])));
  }

  Widget buildTitleBar(BuildContext context) {
    if (widget.loadout.emblemHash == null) {
      return buildTitle(context);
    }
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
        widget.loadout.emblemHash, (definition) {
      return Stack(
        children: <Widget>[
          Positioned.fill(
              child: CachedNetworkImage(
            imageUrl:
                "${BungieApiService.baseUrl}${definition.secondarySpecial}",
            fit: BoxFit.cover,
            alignment: Alignment(-1, 0),
          )),
          buildTitle(context)
        ],
      );
    }, placeholder: buildTitle(context));
  }

  Widget buildTitle(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        child: Text(
          widget.loadout.name.toUpperCase(),
          style: TextStyle(
              color: Colors.grey.shade200, fontWeight: FontWeight.bold),
        ));
  }

  Widget buildButtonBar(BuildContext context) {
    return Container(
        color: Colors.blueGrey.shade800,
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Row(children: [
          Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: RaisedButton(
                    child: TranslatedTextWidget("Equip",
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EquipLoadoutScreen(loadout: widget.loadout),
                        ),
                      );
                    },
                  ))),
          Expanded(
              child: Container(
                  padding: EdgeInsets.all(2),
                  child: RaisedButton(
                    child: TranslatedTextWidget("Edit",
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditLoadoutScreen(loadout: widget.loadout),
                        ),
                      );
                    },
                  ))),
          Expanded(
              child: Container(
                  padding: EdgeInsets.all(2),
                  child: RaisedButton(
                    color: Theme.of(context).errorColor,
                    child: TranslatedTextWidget("Delete",
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {},
                  )))
        ]));
  }

  Widget buildItemRows(BuildContext context) {
    if (itemIndex == null)
      return Container(
        child: AspectRatio(
          aspectRatio: 1,
        ),
      );
    List<Widget> icons = [];

    icons.addAll(buildItemRow(
        context,
        DestinyData.getClassIcon(DestinyClass.Unknown),
        LoadoutItemIndex.genericBucketHashes,
        itemIndex.generic));

    [0, 1, 2].forEach((classType) {
      Map<int, DestinyItemComponent> items = itemIndex.classSpecific
          .map((bucketHash, items) => MapEntry(bucketHash, items[classType]));
      if(items.values.any((i)=>i!=null)){
        icons.addAll(buildItemRow(context, DestinyData.getClassIcon(classType),
          LoadoutItemIndex.classBucketHashes, items));
      }
    });

    return Wrap(
      children: icons,
    );
  }

  List<Widget> buildItemRow(BuildContext context, IconData icon,
      List<int> buckets, Map<int, DestinyItemComponent> items) {
    List<Widget> itemWidgets = [];
    itemWidgets.add(Icon(icon));
    itemWidgets
        .addAll(buckets.map((bucketHash) => itemIcon(items[bucketHash])));
    return itemWidgets
        .map((child) => FractionallySizedBox(
              widthFactor: 1 / (buckets.length + 1),
              child: Container(
                  color: Colors.blueGrey.shade800,
                  padding: EdgeInsets.all(4),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: child,
                  )),
            ))
        .toList();
  }

  Widget itemIcon(DestinyItemComponent item) {
    if (item == null) {
      return ManifestImageWidget<DestinyInventoryItemDefinition>(1835369552);
    }
    return ManifestImageWidget<DestinyInventoryItemDefinition>(item.itemHash);
  }
}
