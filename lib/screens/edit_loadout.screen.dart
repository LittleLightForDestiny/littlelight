import 'dart:math';

import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/select_loadout_background.screen.dart';
import 'package:little_light/screens/select_loadout_item.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_slot.widget.dart';

class EditLoadoutScreen extends StatefulWidget {
  final Loadout loadout;
  final bool forceCreate;
  EditLoadoutScreen({Key key, this.loadout, this.forceCreate = false})
      : super(key: key);

  final ManifestService manifest = new ManifestService();

  @override
  EditLoadoutScreenState createState() => new EditLoadoutScreenState();
}

class EditLoadoutScreenState extends State<EditLoadoutScreen> {
  bool changed = false;
  LoadoutItemIndex _itemIndex;
  DestinyInventoryItemDefinition emblemDefinition;
  Map<int, DestinyInventoryBucketDefinition> bucketDefinitions;
  Loadout _loadout;
  String _nameInputLabel = "";

  TextEditingController _nameFieldController = new TextEditingController();

  @override
  initState() {
    if (widget.loadout != null) {
      _loadout = Loadout.copy(widget.loadout);
    } else {
      _loadout = Loadout.fromScratch();
    }
    _nameFieldController.text = _loadout.name;
    _nameFieldController.addListener(() {
      if (_loadout.name != _nameFieldController.text) {
        _loadout.name = _nameFieldController.text;
        changed = true;
        setState(() {});
      }
    });
    super.initState();
    fetchTranslations();
    loadEmblemDefinition();
    buildItemIndex();
  }

  fetchTranslations() async {
    TranslateService translate = new TranslateService();
    _nameInputLabel = await translate.getTranslation("Loadout Name");
    setState(() {});
  }

  loadEmblemDefinition() async {
    if (_loadout.emblemHash == null) return;
    emblemDefinition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(_loadout.emblemHash);
    setState(() {});
  }

  buildItemIndex() async {
    bucketDefinitions = await widget.manifest
        .getDefinitions<DestinyInventoryBucketDefinition>(loadoutBucketHashes);
    _itemIndex = await InventoryUtils.buildLoadoutItemIndex(_loadout);
    if (mounted) {
      setState(() {});
    }
  }

  Color get emblemColor {
    if (emblemDefinition == null) return Colors.grey.shade900;
    Color color = Color.fromRGBO(
        emblemDefinition.backgroundColor.red,
        emblemDefinition.backgroundColor.green,
        emblemDefinition.backgroundColor.blue,
        1.0);
    return Color.lerp(color, Colors.grey.shade900, .5);
  }

  @override
  Widget build(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: emblemColor,
      appBar: AppBar(
          title: TranslatedTextWidget(
              (widget.loadout == null || widget.forceCreate)
                  ? "Create Loadout"
                  : "Edit Loadout"),
          flexibleSpace: buildAppBarBackground(context)),
      body: ListView.builder(
        padding: EdgeInsets.all(8).copyWith(top: 0, left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
          itemCount: _itemIndex == null ? 2 : loadoutBucketHashes.length + 2,
          itemBuilder: itemBuilder),
      bottomNavigationBar: buildFooter(context),
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    switch (index) {
      case 0:
        return buildNameTextField(context);
      case 1:
        return buildSelectBackgroundButton(context);
    }
    int bucketHash = loadoutBucketHashes[index - 2];
    DestinyInventoryBucketDefinition definition = bucketDefinitions[bucketHash];
    if (bucketHash != null) {
      return LoadoutSlotWidget(
        bucketDefinition: definition,
        key: Key("loadout_slot_$bucketHash"),
        equippedClassItems: _itemIndex.classSpecific[bucketHash],
        equippedGenericItem: _itemIndex.generic[bucketHash],
        unequippedItems: _itemIndex.unequipped[bucketHash],
        onAdd: (equipped, classType) {
          openItemSelect(context, definition, equipped, classType);
        },
        onRemove: (item, equipped) {
          removeItem(equipped, item);
        },
      );
    }
    return Container();
  }

  Widget buildFooter(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    if (!this.changed) return Container(height: paddingBottom);
    return Material(
        color: Theme.of(context).primaryColor,
        elevation: 1,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: buildAppBarBackground(context)),
            Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)
                  .copyWith(bottom: 4 + paddingBottom),
              child: RaisedButton(
                child: TranslatedTextWidget("Save Loadout"),
                onPressed: () {
                  LoadoutsService service = LoadoutsService();
                  service.saveLoadout(_itemIndex.loadout);
                  Navigator.pop(context, _loadout);
                },
              ),
            )
          ],
        ));
  }

  void openItemSelect(
      BuildContext context,
      DestinyInventoryBucketDefinition bucketDef,
      bool equipped,
      int classType) async {
    DestinyItemComponent item = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLoadoutItemScreen(
          bucketDefinition: bucketDef,
          emblemDefinition: emblemDefinition,
          classType: classType,
          idsToAvoid:
              (_itemIndex.loadout.equipped + _itemIndex.loadout.unequipped)
                  .map((i) => i.itemInstanceId),
        ),
      ),
    );
    if (item == null) {
      return;
    }
    int removedItem =
        await _loadout.addItem(item.itemHash, item.itemInstanceId, equipped);
    if(removedItem != null){
      showRemovingExoticMessage(context, removedItem);
    }
    _itemIndex = LoadoutItemIndex(_loadout);
    await _itemIndex.build();
    changed = true;
    setState(() {});
  }

  showRemovingExoticMessage(BuildContext context, int hash) async {
    DestinyInventoryItemDefinition definition = await widget.manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (definition.itemType == DestinyItemType.Weapon) {
      _showSnackBar(
          context,
          TranslatedTextWidget(
              "You can only equip one exotic weapon at a time. Removing {itemName}.",
              replace: {"itemName": definition.displayProperties.name}));
    }
    if (definition.itemType == DestinyItemType.Armor) {
      _showSnackBar(
          context,
          TranslatedTextWidget(
              "You can only equip one exotic armor piece at a time. Removing {itemName}.",
              replace: {"itemName": definition.displayProperties.name}));
    }
  }

  void _showSnackBar(BuildContext context, Widget content) {
    SnackBar snack = SnackBar(duration: Duration(seconds: 3), content: content);
    Scaffold.of(context).showSnackBar(snack);
  }

  void removeItem(bool equipped, DestinyItemComponent item) async {
    var def = await ManifestService()
        .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
    if (equipped) {
      _itemIndex.removeEquippedItem(item, def);
    } else {
      _itemIndex.removeUnequippedItem(item, def);
    }
    changed = true;
    setState(() {});
  }

  Widget buildNameTextField(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: TextField(
          autocorrect: false,
          controller: _nameFieldController,
          decoration: InputDecoration(labelText: _nameInputLabel),
        ));
  }

  Widget buildSelectBackgroundButton(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: RaisedButton(
          child: TranslatedTextWidget("Select Loadout Background"),
          onPressed: () async {
            var emblemHash = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectLoadoutBackgroundScreen(),
              ),
            );
            if (emblemHash != null) {
              _loadout.emblemHash = emblemHash;
              changed = true;
              loadEmblemDefinition();
            }
          },
        ));
  }

  buildAppBarBackground(BuildContext context) {
    if (emblemDefinition == null) return Container();
    if (emblemDefinition.secondarySpecial.length == 0) return Container();
    return Container(
        constraints: BoxConstraints.expand(),
        child: QueuedNetworkImage(
            imageUrl: BungieApiService.url(emblemDefinition.secondarySpecial),
            fit: BoxFit.cover,
            alignment: Alignment(-.8, 0)));
  }
}
