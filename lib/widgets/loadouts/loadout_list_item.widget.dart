import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/pages/edit_loadout.screen.dart';
import 'package:little_light/pages/equip_loadout.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/littlelight_custom.dialog.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class LoadoutListItemWidget extends StatefulWidget {
  final Map<String, LoadoutItemIndex> itemIndexes;
  final Loadout loadout;
  final Function onChange;
  const LoadoutListItemWidget(this.loadout,
      {Key key, this.itemIndexes, this.onChange})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadoutListItemWidgetState();
  }
}

class LoadoutListItemWidgetState extends State<LoadoutListItemWidget> with LoadoutsConsumer{
  LoadoutItemIndex _itemIndex;
  Loadout _loadout;
  @override
  initState() {
    super.initState();

    _loadout = widget.loadout;
    if (itemIndex == null) {
      buildItemIndex();
    }
  }

  LoadoutItemIndex get itemIndex {
    return _itemIndex ?? widget.itemIndexes[_loadout.assignedId];
  }

  buildItemIndex() async {
    _itemIndex = await InventoryUtils.buildLoadoutItemIndex(_loadout);
    widget.itemIndexes[_loadout.assignedId] = _itemIndex;
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
            color: Theme.of(context).colorScheme.secondaryVariant,
            child: Column(children: [
              Container(
                height: kToolbarHeight,
                child: buildTitleBar(context),
              ),
              buildItemRows(context),
              buildButtonBar(context)
            ])));
  }

  Widget buildTitleBar(BuildContext context) {
    if (_loadout.emblemHash == null) {
      return buildTitle(context);
    }
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
      _loadout.emblemHash,
      (definition) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
                child: QueuedNetworkImage(
              imageUrl: BungieApiService.url(definition.secondarySpecial),
              fit: BoxFit.cover,
              alignment: Alignment(-1, 0),
            )),
            buildTitle(context)
          ],
        );
      },
      placeholder: buildTitle(context),
      key: Key("emblem_${_loadout.emblemHash}"),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
        child: Text(
          _loadout.name?.toUpperCase() ?? "",
          style: TextStyle(
              color: Colors.grey.shade200, fontWeight: FontWeight.bold),
        ));
  }

  Widget buildButtonBar(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.secondaryVariant,
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Row(children: [
          Expanded(
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: ElevatedButton(
                    style:
                        ButtonStyle(visualDensity: VisualDensity.comfortable),
                    child: TranslatedTextWidget("Equip",
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EquipLoadoutScreen(loadout: _loadout),
                        ),
                      );
                    },
                  ))),
          Expanded(
              child: Container(
                  padding: EdgeInsets.all(2),
                  child: ElevatedButton(
                    style:
                        ButtonStyle(visualDensity: VisualDensity.comfortable),
                    child: TranslatedTextWidget("Edit",
                        uppercase: true,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      var loadout = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditLoadoutScreen(loadout: _loadout),
                        ),
                      );
                      if (loadout != null) {
                        _loadout = loadout;
                        await buildItemIndex();
                        if (widget.onChange != null) {
                          widget.onChange();
                        }
                      }
                    },
                  ))),
          Expanded(
              child: Container(
                  padding: EdgeInsets.all(2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.comfortable,
                        primary: Theme.of(context).errorColor),
                    child: TranslatedTextWidget("Delete",
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      deletePressed(context);
                    },
                  )))
        ]));
  }

  Future<void> deletePressed(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => LittleLightCustomDialog.withYesNoButtons(
                Container(
                    padding: EdgeInsets.all(8),
                    child: TranslatedTextWidget(
                      "Do you really want to delete the loadout {loadoutName} ?",
                      replace: {"loadoutName": _loadout.name},
                      style: TextStyle(fontSize: 16),
                    )),
                title: Text(_loadout?.name?.toUpperCase() ?? ""),
                maxWidth: 400, yesPressed: () async {
              await loadoutService.deleteLoadout(_loadout);
              Navigator.of(context).pop();
              if (widget.onChange != null) {
                widget.onChange();
              }
            }, noPressed: () {
              Navigator.of(context).pop();
            }));
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

    DestinyClass.values.forEach((classType) {
      Map<int, DestinyItemComponent> items = itemIndex.classSpecific
          .map((bucketHash, items) => MapEntry(bucketHash, items[classType]));
      if (items.values.any((i) => i != null)) {
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
                  color: Theme.of(context).colorScheme.secondaryVariant,
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
      return ManifestImageWidget<DestinyInventoryItemDefinition>(1835369552,
          key: Key("item_icon_empty"));
    }
    var instance = ProfileService().getInstanceInfo(item?.itemInstanceId);
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
        item.itemHash,
        (def) => ItemIconWidget.builder(
            item: item,
            definition: def,
            instanceInfo: instance,
            key: Key("item_icon_${item.itemInstanceId}")));
  }
}
