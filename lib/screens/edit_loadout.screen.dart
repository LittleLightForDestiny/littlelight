import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/select_loadout_background.screen.dart';
import 'package:little_light/screens/select_loadout_item.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/loadouts/loadout_slot.widget.dart';
import 'package:uuid/uuid.dart';

class EditLoadoutScreen extends StatefulWidget {
  final Loadout loadout;
  final bool forceCreate;
  EditLoadoutScreen({Key key, this.loadout, this.forceCreate = false}) : super(key: key);

  final List<int> bucketOrder = [
    InventoryBucket.subclass,
    InventoryBucket.kineticWeapons,
    InventoryBucket.energyWeapons,
    InventoryBucket.powerWeapons,
    InventoryBucket.helmet,
    InventoryBucket.gauntlets,
    InventoryBucket.chestArmor,
    InventoryBucket.legArmor,
    InventoryBucket.classArmor,
    InventoryBucket.ghost,
    InventoryBucket.vehicle,
    InventoryBucket.ships,
  ];

  final List<int> weaponBuckets = [
    InventoryBucket.kineticWeapons,
    InventoryBucket.energyWeapons,
    InventoryBucket.powerWeapons,
  ];

  final List<int> armorBuckets = [
    InventoryBucket.helmet,
    InventoryBucket.gauntlets,
    InventoryBucket.chestArmor,
    InventoryBucket.legArmor,
  ];

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
      _loadout = Loadout.fromMap(widget.loadout.toMap());
    } else {
      String uuid = Uuid().v4();
      _loadout = Loadout(uuid, "", null, [], []);
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
        .getDefinitions<DestinyInventoryBucketDefinition>(widget.bucketOrder);
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
    return Scaffold(
      backgroundColor: emblemColor,
      appBar: AppBar(
          title: TranslatedTextWidget(
              (widget.loadout == null || widget.forceCreate) ? "Create Loadout" : "Edit Loadout"),
          flexibleSpace: buildAppBarBackground(context)),
      body: ListView.builder(
          itemCount: _itemIndex == null ? 2 : widget.bucketOrder.length + 2,
          padding: EdgeInsets.all(8),
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
    int bucketHash = widget.bucketOrder[index - 2];
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
    if (!this.changed) return Container(height: 0);
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    return Material(
        color: Theme.of(context).primaryColor,
        elevation: 1,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: buildAppBarBackground(context)),
            Container(
              constraints: BoxConstraints(minWidth: double.infinity),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4).copyWith(bottom: 4 + paddingBottom),
              child: RaisedButton(
                child: TranslatedTextWidget("Save Loadout"),
                onPressed: () {
                  LittleLightService service = LittleLightService();
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
    var def = await ManifestService()
        .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);

    if (equipped) {
      if (def.inventory.tierType == TierType.Exotic) {
        await removeBlockingExotics(context, def);
      }
      _itemIndex.addEquippedItem(item, def);
    } else {
      _itemIndex.addUnequippedItem(item, def);
    }
    changed = true;
    setState(() {});
  }

  Future<DestinyInventoryItemDefinition> removeBlockingExotics(
      BuildContext context, DestinyInventoryItemDefinition definition) async {
    if (definition.itemType == ItemType.weapon) {
      for (var bucket in widget.weaponBuckets) {
        DestinyItemComponent item = _itemIndex.generic[bucket];
        if (item == null) continue;
        DestinyInventoryItemDefinition def =
            await widget.manifest.getItemDefinition(item.itemHash);
        if (def.inventory.tierType != TierType.Exotic) continue;
        _itemIndex.removeEquippedItem(item, def);
        _showSnackBar(
            context,
            TranslatedTextWidget(
                "You can only equip one exotic weapon at a time. Removing {itemName}.",
                replace: {"itemName": def.displayProperties.name}));
        return def;
      }
    }
    if (definition.itemType == ItemType.armor) {
      for (var bucket in widget.armorBuckets) {
        DestinyItemComponent item =
            _itemIndex.classSpecific[bucket][definition.classType];
        if (item == null) continue;
        DestinyInventoryItemDefinition def =
            await widget.manifest.getItemDefinition(item.itemHash);
        if (def.inventory.tierType != TierType.Exotic) continue;
        _itemIndex.removeEquippedItem(item, def);
        _showSnackBar(
            context,
            TranslatedTextWidget(
                "You can only equip one exotic armor piece at a time. Removing {itemName}.",
                replace: {"itemName": def.displayProperties.name}));
        return def;
      }
    }

    return null;
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
    if(emblemDefinition.secondarySpecial.length == 0) return Container();
    return Container(
        constraints: BoxConstraints.expand(),
        child: QueuedNetworkImage(
            imageUrl: BungieApiService.url(emblemDefinition.secondarySpecial),
            fit: BoxFit.cover,
            alignment: Alignment(-.8, 0)));
  }
}
