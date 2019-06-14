import 'dart:async';

import 'dart:math' as math;

import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/screens/edit_loadout.screen.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/smaller_switch.dart';
import 'package:little_light/widgets/option_sheets/loadout_select_sheet.widget.dart';
import 'package:shimmer/shimmer.dart';

class CharacterOptionsSheet extends StatefulWidget {
  final DestinyCharacterComponent character;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();

  CharacterOptionsSheet({Key key, this.character}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CharacterOptionsSheetState();
  }
}

class CharacterOptionsSheetState extends State<CharacterOptionsSheet> {
  LoadoutItemIndex maxLightLoadout;
  double maxLight;
  List<Loadout> loadouts;
  List<DestinyItemComponent> itemsInPostmaster;

  final TextStyle headerStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

  final TextStyle buttonStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 12);

  bool loadoutWeapons = true;

  bool loadoutArmor = true;

  @override
  void initState() {
    super.initState();
    getItemsInPostmaster();
    getMaxLightLoadout();
    getLoadouts();
  }

  void getLoadouts() async {
    var littlelight = LittleLightService();
    this.loadouts = await littlelight.getLoadouts();
    if (mounted) {
      setState(() {});
    }
  }

  void getItemsInPostmaster() {
    var all =
        widget.profile.getCharacterInventory(widget.character.characterId);
    var inPostmaster =
        all.where((i) => i.bucketHash == InventoryBucket.lostItems).toList();
    itemsInPostmaster = inPostmaster;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: (){},
      child:SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildEquipBlock(),
              buildLoadoutBlock(),
              buildCreateLoadoutBlock(),
              Container(height: 8,),
              buildPullFromPostmaster(),
            ])));
  }

  Widget buildEquipBlock() {
    return Column(children: [
      buildBlockHeader(
          TranslatedTextWidget("Equip", uppercase: true, style: headerStyle)),
      IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            child: buildActionButton(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TranslatedTextWidget(
                "Max Light",
                style: buttonStyle,
                uppercase: true,
                textAlign: TextAlign.center,
              ),
              Container(height: 2),
              maxLight == null
                  ? Shimmer.fromColors(
                      period: Duration(milliseconds: 600),
                      baseColor: Colors.transparent,
                      highlightColor: Colors.white,
                      child:
                          Container(width: 50, height: 14, color: Colors.white))
                  : Text(
                      "${maxLight?.toStringAsFixed(1) ?? ""}",
                      style: buttonStyle.copyWith(color: Colors.amber.shade300),
                    )
            ],
          ),
          onTap: () async {
            Navigator.of(context).pop();
            InventoryService().transferLoadout(
                maxLightLoadout.loadout, widget.character.characterId, true);
          },
        )),
        Container(width: 4),
        Expanded(
            child: buildActionButton(
          TranslatedTextWidget(
            "Random Weapons",
            style: buttonStyle,
            uppercase: true,
            textAlign: TextAlign.center,
          ),
          onTap: () async {
            Navigator.pop(context);
            randomizeWeapons();
          },
        )),
        Container(width: 4),
        Expanded(
            child: buildActionButton(
          TranslatedTextWidget(
            "Random Armor",
            style: buttonStyle,
            uppercase: true,
            textAlign: TextAlign.center,
          ),
          onTap: () async {
            Navigator.pop(context);
            randomizeArmor();
          },
        )),
      ]))
    ]);
  }

  Widget buildLoadoutBlock() {
    if ((loadouts?.length ?? 0) == 0) {
      return Container();
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      buildBlockHeader(
        TranslatedTextWidget(
          "Loadouts",
          uppercase: true,
          style: headerStyle,
        ),
      ),
      IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
            Expanded(
                child: buildActionButton(
              TranslatedTextWidget(
                "Transfer",
                style: buttonStyle,
                uppercase: true,
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                Navigator.of(context).pop();
                showModalBottomSheet(
                    context: context,
                    builder: (context) => LoadoutSelectSheet(
                        character: widget.character,
                        loadouts: loadouts,
                        onSelect: (loadout) => InventoryService()
                            .transferLoadout(
                                loadout, widget.character.characterId)));
              },
            )),
            Container(width: 4),
            Expanded(
                child: buildActionButton(
              TranslatedTextWidget(
                "Equip",
                style: buttonStyle,
                uppercase: true,
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                Navigator.of(context).pop();
                showModalBottomSheet(
                    context: context,
                    builder: (context) => LoadoutSelectSheet(
                        character: widget.character,
                        loadouts: loadouts,
                        onSelect: (loadout) => InventoryService()
                            .transferLoadout(
                                loadout, widget.character.characterId, true)));
              },
            )),
          ]))
    ]);
  }

  Widget buildCreateLoadoutBlock() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      buildBlockHeader(
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          TranslatedTextWidget("Create Loadout",
              uppercase: true, style: headerStyle),
          Row(children: [
            TranslatedTextWidget("Weapons",
                uppercase: true, style: headerStyle),
            Container(width: 2),
            SmallerSwitch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: loadoutWeapons,
                onChanged: (value) {
                  setState(() {
                    loadoutWeapons = value;
                  });
                }),
            Container(width: 6),
            TranslatedTextWidget("Armor", uppercase: true, style: headerStyle),
            Container(width: 2),
            SmallerSwitch(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: loadoutArmor,
                onChanged: (value) {
                  setState(() {
                    loadoutArmor = value;
                  });
                }),
          ])
        ]),
      ),
      IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
            Expanded(
                child: buildActionButton(
              TranslatedTextWidget(
                "All",
                style: buttonStyle,
                uppercase: true,
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                var itemIndex = await createLoadout(true);
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => EditLoadoutScreen(
                          loadout: itemIndex.loadout,
                          forceCreate: true,
                        )));
              },
            )),
            Container(width: 4),
            Expanded(
                child: buildActionButton(
              TranslatedTextWidget(
                "Equipped",
                style: buttonStyle,
                uppercase: true,
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                var itemIndex = await createLoadout();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => EditLoadoutScreen(
                          loadout: itemIndex.loadout,
                          forceCreate: true,
                        )));
              },
            )),
          ]))
    ]);
  }

  Widget buildPullFromPostmaster() {
    if ((itemsInPostmaster?.length ?? 0) <= 0) return Container();
    return buildActionButton(
      TranslatedTextWidget(
                "Pull everything from postmaster",
                style: buttonStyle,
                uppercase: true,
                textAlign: TextAlign.center,
              ),
      onTap: () {
        Navigator.of(context).pop();
        InventoryService().transferMultiple(
            itemsInPostmaster
                .map((i) => ItemInventoryState(widget.character.characterId, i))
                .toList(),
            ItemDestination.Character,
            widget.character.characterId);
      },
    );
  }

  Widget buildBlockHeader(Widget content) {
    return Container(
        child: HeaderWidget(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(4),
          child: content,
        ),
        padding: EdgeInsets.symmetric(vertical: 4));
  }

  Widget buildActionButton(Widget content, {Function onTap}) {
    return Stack(
      fit: StackFit.loose,
      alignment: Alignment.center,
      children: <Widget>[
        Positioned.fill(
            child: Material(
          color: Colors.blueGrey.shade500,
        )),
        Container(padding: EdgeInsets.all(8), child: content),
        Positioned.fill(
            child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                )))
      ],
    );
  }

  Future<LoadoutItemIndex> createLoadout([includeUnequipped = false]) async {
    var itemIndex = new LoadoutItemIndex();
    itemIndex.loadout.emblemHash = widget.character.emblemHash;
    var slots = LoadoutItemIndex.classBucketHashes +
        LoadoutItemIndex.genericBucketHashes;
    var equipment =
        widget.profile.getCharacterEquipment(widget.character.characterId);
    var equipped = equipment.where((i) => slots.contains(i.bucketHash));
    for (var item in equipped) {
      var def = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      if ((def.itemType == DestinyItemType.Weapon || def.itemType == DestinyItemType.Subclass) && loadoutWeapons) {
        itemIndex.addEquippedItem(item, def);
      }
      if (def.itemType == DestinyItemType.Armor && loadoutArmor) {
        itemIndex.addEquippedItem(item, def);
      }
    }
    if (!includeUnequipped) return itemIndex;
    var inventory =
        widget.profile.getCharacterInventory(widget.character.characterId);
    var unequipped = inventory.where((i) => slots.contains(i.bucketHash));
    for (var item in unequipped) {
      var def = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      if (def.itemType == DestinyItemType.Weapon && loadoutWeapons) {
        itemIndex.addUnequippedItem(item, def);
      }
      if (def.itemType == DestinyItemType.Armor && loadoutArmor) {
        itemIndex.addUnequippedItem(item, def);
      }
    }
    return itemIndex;
  }

  randomizeWeapons() async {
    randomizeLoadout([
      InventoryBucket.kineticWeapons,
      InventoryBucket.energyWeapons,
      InventoryBucket.powerWeapons
    ]);
  }

  randomizeArmor() async {
    randomizeLoadout([
      InventoryBucket.helmet,
      InventoryBucket.gauntlets,
      InventoryBucket.chestArmor,
      InventoryBucket.legArmor,
      InventoryBucket.classArmor,
    ]);
  }

  randomizeLoadout(List<int> requiredSlots) async {
    LoadoutItemIndex randomLoadout = new LoadoutItemIndex();
    var allItems = widget.profile
        .getAllItems()
        .where((i) => i.itemInstanceId != null)
        .toList();
    Map<int, String> slots = {};
    int exoticSlot;
    for (int i = 0; i < 1000; i++) {
      var random = math.Random();
      var index = random.nextInt(allItems.length);
      var item = allItems[index];
      var itemDef = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      var itemBucket = itemDef.inventory.bucketTypeHash;
      var tierType = itemDef.inventory.tierType;
      var classType = itemDef.classType;
      if (requiredSlots.contains(itemBucket) &&
          [DestinyClass.Unknown, widget.character.classType]
              .contains(classType)) {
        if (tierType == TierType.Exotic && exoticSlot == null) {
          slots[itemBucket] = item.itemInstanceId;
          exoticSlot = itemBucket;
        }
        if (tierType != TierType.Exotic && exoticSlot != itemBucket) {
          slots[itemBucket] = item.itemInstanceId;
        }
      }
    }

    for (var j in slots.values) {
      var item = allItems.firstWhere((i) => i.itemInstanceId == j);
      var itemDef = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      print(itemDef.displayProperties.name);
      randomLoadout.addEquippedItem(item, itemDef);
    }

    InventoryService().transferLoadout(randomLoadout.loadout, widget.character.characterId, true);
  }

  getMaxLightLoadout() async {
    var allItems = widget.profile.getAllItems();
    var instancedItems =
        allItems.where((i) => i.itemInstanceId != null).toList();
    instancedItems.sort((itemA, itemB) =>
        InventoryUtils.sortDestinyItems(itemA, itemB));
    LoadoutItemIndex maxLightLoadout = new LoadoutItemIndex();
    LoadoutItemIndex exoticPieces = new LoadoutItemIndex();
    var hashes = instancedItems.map((i) => i.itemHash);
    var defs = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(hashes);
    for (var item in instancedItems) {
      var def = defs[item.itemHash];
      if (def.classType != widget.character.classType &&
          def.classType != DestinyClass.Unknown) {
        continue;
      }
      if (![DestinyItemType.Weapon, DestinyItemType.Armor]
          .contains(def.itemType)) {
        continue;
      }
      if (def.inventory.tierType == TierType.Exotic) {
        if (exoticPieces.haveEquippedItem(def)) {
          continue;
        }
        exoticPieces.addEquippedItem(item, def);
      } else {
        if (maxLightLoadout.haveEquippedItem(def)) {
          continue;
        }
        maxLightLoadout.addEquippedItem(item, def);
      }
    }
    var exoticWeapon =
        getHighestLightExoticWeapon(maxLightLoadout, exoticPieces);
    var exoticArmor = getHighestLightExoticArmor(maxLightLoadout, exoticPieces);

    if (exoticWeapon != null) {
      var def = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(exoticWeapon.itemHash);
      maxLightLoadout.addEquippedItem(exoticWeapon, def);
    }

    if (exoticArmor != null) {
      var def = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(exoticArmor.itemHash);
      maxLightLoadout.addEquippedItem(exoticArmor, def);
    }
    int totalLight = 0;
    for (var weapon in maxLightLoadout.generic.values) {
      if (weapon == null) continue;
      var instance = widget.profile.getInstanceInfo(weapon.itemInstanceId);
      totalLight += instance?.primaryStat?.value ?? 0;
    }
    for (var armorItems in maxLightLoadout.classSpecific.values) {
      var armor = armorItems[widget.character.classType];
      if (armor == null) continue;
      var instance = widget.profile.getInstanceInfo(armor.itemInstanceId);
      totalLight += instance?.primaryStat?.value ?? 0;
    }
    this.maxLightLoadout = maxLightLoadout;
    this.maxLight = totalLight / 8;
    if (mounted) {
      setState(() {});
    }
  }

  DestinyItemComponent getHighestLightExoticWeapon(
      LoadoutItemIndex nonExotic, LoadoutItemIndex exotic) {
    int lightDifference = 0;
    DestinyItemComponent exoticToReplace;
    for (var bucketHash in exotic.generic.keys) {
      var exoticWeapon = exotic.generic[bucketHash];
      var nonExoticWeapon = nonExotic.generic[bucketHash];
      var exoticInstance =
          widget.profile.getInstanceInfo(exoticWeapon?.itemInstanceId);
      var nonExoticInstance =
          widget.profile.getInstanceInfo(nonExoticWeapon?.itemInstanceId);
      var exoticPower = exoticInstance?.primaryStat?.value ?? 0;
      var nonExoticPower = nonExoticInstance?.primaryStat?.value ?? 0;
      var diff = exoticPower - nonExoticPower;
      if (diff > lightDifference) {
        exoticToReplace = exotic.generic[bucketHash];
        lightDifference = diff;
      }
    }
    return exoticToReplace;
  }

  DestinyItemComponent getHighestLightExoticArmor(
      LoadoutItemIndex nonExotic, LoadoutItemIndex exotic) {
    int lightDifference = 0;
    DestinyItemComponent exoticToReplace;
    for (var bucketHash in exotic.classSpecific.keys) {
      var exoticArmor =
          exotic.classSpecific[bucketHash][widget.character.classType];
      var nonExoticArmor =
          nonExotic.classSpecific[bucketHash][widget.character.classType];
      var exoticInstance =
          widget.profile.getInstanceInfo(exoticArmor?.itemInstanceId);
      var nonExoticInstance =
          widget.profile.getInstanceInfo(nonExoticArmor?.itemInstanceId);
      var exoticPower = exoticInstance?.primaryStat?.value ?? 0;
      var nonExoticPower = nonExoticInstance?.primaryStat?.value ?? 0;
      var diff = exoticPower - nonExoticPower;
      if (diff > lightDifference) {
        exoticToReplace =
            exotic.classSpecific[bucketHash][widget.character.classType];
        lightDifference = diff;
      }
    }
    return exoticToReplace;
  }
}
