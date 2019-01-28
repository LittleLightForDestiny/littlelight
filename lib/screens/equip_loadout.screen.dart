import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_destinations.widget.dart';

class EquipLoadoutScreen extends StatefulWidget {
  final Loadout loadout;
  const EquipLoadoutScreen({Key key, this.loadout}) : super(key: key);

  @override
  EquipLoadoutScreenState createState() => new EquipLoadoutScreenState();
}

class EquipLoadoutScreenState extends State<EquipLoadoutScreen> {
  LoadoutItemIndex _itemIndex;
  DestinyInventoryItemDefinition emblemDefinition;
  @override
  initState() {
    super.initState();
    buildItemIndex();
  }

  buildItemIndex() async {
    _itemIndex = await InventoryUtils.buildLoadoutItemIndex(widget.loadout,
        onlyEquipped: false);

    ManifestService manifest = new ManifestService();
    emblemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(widget.loadout.emblemHash);
    if (mounted) {
      setState(() {});
    }
  }

  Color get emblemColor{
    if(emblemDefinition == null) return Colors.grey.shade900;
    Color color =  Color.fromRGBO(emblemDefinition.backgroundColor.red, emblemDefinition.backgroundColor.green, emblemDefinition.backgroundColor.blue, 1.0);
    return Color.lerp(color, Colors.grey.shade900, .5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: emblemColor,
        appBar: AppBar(
            actions: <Widget>[
              IconButton(icon:Icon(Icons.refresh), onPressed: () {
                var profile = new ProfileService();
                profile.fetchProfileData();
              },)
            ],
            title: Text(widget.loadout.name),
            flexibleSpace: buildAppBarBackground(context)),
        bottomNavigationBar: LoadoutDestinationsWidget(widget.loadout),
        body: ListView(padding: EdgeInsets.all(8), children: <Widget>[
          HeaderWidget(
            child: TranslatedTextWidget("Items to Equip",
                uppercase: true, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
              padding: EdgeInsets.all(8), child: buildEquippedItems(context)),
          (_itemIndex?.unequippedCount ?? 0) == 0
              ? Container()
              : HeaderWidget(
                  child: TranslatedTextWidget("Items to Transfer",
                      uppercase: true,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
          (_itemIndex?.unequippedCount ?? 0) == 0
              ? Container()
              : Container(
                  padding: EdgeInsets.all(8),
                  child: buildUnequippedItems(context)),
        ]));
  }

  buildAppBarBackground(BuildContext context) {
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(
        widget.loadout.emblemHash,
        (def) => Container(
            constraints: BoxConstraints.expand(),
            child: CachedNetworkImage(
                imageUrl: "${BungieApiService.baseUrl}${def.secondarySpecial}",
                fit: BoxFit.cover,
                alignment: Alignment(-.8, 0))));
  }

  Widget buildEquippedItems(BuildContext context) {
    if (_itemIndex == null)
      return Container(
        child: AspectRatio(
          aspectRatio: 1,
        ),
      );
    List<Widget> icons = [];
    if (_itemIndex.generic != null) {
      icons.addAll(buildItemRow(
          context,
          DestinyData.getClassIcon(DestinyClass.Unknown),
          LoadoutItemIndex.genericBucketHashes,
          _itemIndex.generic));
    }
    if (_itemIndex.classSpecific != null) {
      _itemIndex.classSpecific.forEach((classType, items) {
        icons.addAll(buildItemRow(context, DestinyData.getClassIcon(classType),
            LoadoutItemIndex.classBucketHashes, items));
      });
    }

    return Wrap(
      children: icons,
    );
  }

  Widget buildUnequippedItems(BuildContext context) {
    if (_itemIndex == null)
      return Container(
        child: AspectRatio(
          aspectRatio: 1,
        ),
      );
    if (_itemIndex.unequipped == null) return Container();
    List<DestinyItemComponent> items = [];
    List<int> bucketHashes = LoadoutItemIndex.genericBucketHashes +
        LoadoutItemIndex.classBucketHashes;
    bucketHashes.forEach((bucketHash) {
      if (_itemIndex.unequipped[bucketHash] != null) {
        items += _itemIndex.unequipped[bucketHash];
      }
    });
    return Wrap(
      children: items
          .map((item) => FractionallySizedBox(
              widthFactor: 1 / 7,
              child: Container(
                  padding: EdgeInsets.all(4),
                  child: AspectRatio(aspectRatio: 1, child: itemIcon(item)))))
          .toList(),
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
