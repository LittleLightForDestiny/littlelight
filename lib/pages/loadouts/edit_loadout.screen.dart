// @dart=2.9

import 'dart:math';

import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/pages/loadouts/select_loadout_background.screen.dart';
import 'package:little_light/pages/loadouts/select_loadout_item.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/services/littlelight/loadouts.consumer.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/utils/loadout_utils.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_slot.widget.dart';

class EditLoadoutScreen extends StatefulWidget {
  final Loadout loadout;
  final bool forceCreate;
  EditLoadoutScreen({Key key, this.loadout, this.forceCreate = false}) : super(key: key);

  @override
  EditLoadoutScreenState createState() => EditLoadoutScreenState();
}

class EditLoadoutScreenState extends State<EditLoadoutScreen>
    with LanguageConsumer, LoadoutsConsumer, ManifestConsumer {
  bool changed = false;
  LoadoutItemIndex _itemIndex;
  DestinyInventoryItemDefinition emblemDefinition;
  Map<int, DestinyInventoryBucketDefinition> bucketDefinitions;
  Loadout _loadout;
  String _nameInputLabel = "";

  TextEditingController _nameFieldController = TextEditingController();

  @override
  initState() {
    super.initState();
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
    fetchTranslations();
    loadEmblemDefinition();
    buildItemIndex();
  }

  fetchTranslations() async {
    _nameInputLabel = await languageService.getTranslation("Loadout Name");
    setState(() {});
  }

  loadEmblemDefinition() async {
    if (_loadout.emblemHash == null) return;
    emblemDefinition = await manifest.getDefinition<DestinyInventoryItemDefinition>(_loadout.emblemHash);
    setState(() {});
  }

  buildItemIndex() async {
    bucketDefinitions =
        await manifest.getDefinitions<DestinyInventoryBucketDefinition>(InventoryBucket.loadoutBucketHashes);
    _itemIndex = await InventoryUtils.buildLoadoutItemIndex(_loadout);
    if (mounted) {
      setState(() {});
    }
  }

  Color get emblemColor {
    if (emblemDefinition == null) return Theme.of(context).colorScheme.background;
    Color color = Color.fromRGBO(emblemDefinition.backgroundColor.red, emblemDefinition.backgroundColor.green,
        emblemDefinition.backgroundColor.blue, 1.0);
    return Color.lerp(color, Theme.of(context).colorScheme.background, .5);
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).padding;
    final creating = (widget.loadout == null || widget.forceCreate);
    return Scaffold(
      backgroundColor: emblemColor,
      appBar: AppBar(
          title: creating ? TranslatedTextWidget("Create Loadout") : TranslatedTextWidget("Edit Loadout"),
          flexibleSpace: buildAppBarBackground(context)),
      body: ListView.builder(
          padding:
              EdgeInsets.all(8).copyWith(top: 0, left: max(screenPadding.left, 8), right: max(screenPadding.right, 8)),
          itemCount: _itemIndex == null ? 2 : InventoryBucket.loadoutBucketHashes.length + 2,
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
    int bucketHash = InventoryBucket.loadoutBucketHashes[index - 2];
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).copyWith(bottom: 4 + paddingBottom),
              child: ElevatedButton(
                child: TranslatedTextWidget("Save Loadout"),
                onPressed: () {
                  loadoutService.saveLoadout(_itemIndex.loadout);
                  Navigator.pop(context, _loadout);
                },
              ),
            )
          ],
        ));
  }

  void openItemSelect(
      BuildContext context, DestinyInventoryBucketDefinition bucketDef, bool equipped, DestinyClass classType) async {
    ItemWithOwner item = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectLoadoutItemScreen(
          bucketDefinition: bucketDef,
          emblemDefinition: emblemDefinition,
          classType: classType,
          idsToAvoid: (_itemIndex.loadout.equipped + _itemIndex.loadout.unequipped).map((i) => i.itemInstanceId),
        ),
      ),
    );
    if (item == null) {
      return;
    }
    int removedItem = await _loadout.addItem(item.item.itemHash, item.item.itemInstanceId, equipped);
    if (removedItem != null) {
      showRemovingExoticMessage(context, removedItem);
    }
    _itemIndex = LoadoutItemIndex(_loadout);
    await _itemIndex.build();
    changed = true;
    setState(() {});
  }

  showRemovingExoticMessage(BuildContext context, int hash) async {
    DestinyInventoryItemDefinition definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(hash);
    if (definition.itemType == DestinyItemType.Weapon) {
      _showSnackBar(
          context,
          TranslatedTextWidget("You can only equip one exotic weapon at a time. Removing {itemName}.",
              replace: {"itemName": definition.displayProperties.name}));
    }
    if (definition.itemType == DestinyItemType.Armor) {
      _showSnackBar(
          context,
          TranslatedTextWidget("You can only equip one exotic armor piece at a time. Removing {itemName}.",
              replace: {"itemName": definition.displayProperties.name}));
    }
  }

  void _showSnackBar(BuildContext context, Widget content) {
    SnackBar snack = SnackBar(duration: Duration(seconds: 3), content: content);
    ScaffoldMessenger.of(context).showSnackBar(snack);
  }

  void removeItem(bool equipped, DestinyItemComponent item) async {
    var def = await manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
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
        child: ElevatedButton(
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
