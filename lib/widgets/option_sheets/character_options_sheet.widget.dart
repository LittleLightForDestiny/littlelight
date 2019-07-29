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
import 'package:little_light/services/inventory/inventory.service.dart' as prefix0;
import 'package:little_light/services/littlelight/loadouts.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/item_sort_parameter.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/smaller_switch.dart';
import 'package:little_light/widgets/option_sheets/free_slots_slider.widget.dart';
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
  Map<int, DestinyItemComponent> maxLightLoadout;
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
    var littlelight = LoadoutsService();
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
        onTap: () {},
        child: Container(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            child: SingleChildScrollView(
                padding: EdgeInsets.all(8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildEquipBlock(),
                      buildLoadoutBlock(),
                      buildCreateLoadoutBlock(),
                      Container(
                        height: 8,
                      ),
                      buildPullFromPostmaster(),
                    ]))));
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
            LoadoutItemIndex loadout = LoadoutItemIndex();
            var equipment = widget.profile.getCharacterEquipment(widget.character.characterId);
            for(var bucket in maxLightLoadout.keys){
              var item = maxLightLoadout[bucket];
              var power = widget.profile.getInstanceInfo(item.itemInstanceId)?.primaryStat?.value ?? 0;
              var equipped = equipment.firstWhere((i)=>i.bucketHash == bucket, orElse:null);
              var equippedPower = widget.profile.getInstanceInfo(equipped?.itemInstanceId)?.primaryStat?.value ?? 0;
              var def = await widget.manifest.getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
              if(power > equippedPower){
                loadout.addEquippedItem(item, def);
              }
            }
            InventoryService().transferLoadout(
                loadout.loadout, widget.character.characterId, true);
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
                int freeSlots = UserSettingsService().defaultFreeSlots;
                showModalBottomSheet(
                    context: context,
                    builder: (context) => LoadoutSelectSheet(
                        header: FreeSlotsSliderWidget(
                          initialValue: freeSlots,
                          onChanged: (free) {
                            freeSlots = free;
                          },
                        ),
                        character: widget.character,
                        loadouts: loadouts,
                        onSelect: (loadout) => InventoryService()
                            .transferLoadout(
                                loadout,
                                widget.character.characterId,
                                false,
                                freeSlots)));
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
                int freeSlots = 0;
                showModalBottomSheet(
                    context: context,
                    builder: (context) => LoadoutSelectSheet(
                        header: FreeSlotsSliderWidget(
                          onChanged: (free) {
                            freeSlots = free;
                          },
                        ),
                        character: widget.character,
                        loadouts: loadouts,
                        onSelect: (loadout) => InventoryService()
                            .transferLoadout(
                                loadout,
                                widget.character.characterId,
                                true,
                                freeSlots)));
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
      if ((def.itemType == DestinyItemType.Weapon ||
              def.itemType == DestinyItemType.Subclass) &&
          loadoutWeapons) {
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

    InventoryService().transferLoadout(
        randomLoadout.loadout, widget.character.characterId, true);
  }

  getMaxLightLoadout() async {
    var allItems = widget.profile.getAllItems();
    var instancedItems =
        allItems.where((i) => i.itemInstanceId != null).toList();
    instancedItems.sort((itemA, itemB) =>
        InventoryUtils.sortDestinyItems(itemA, itemB, sortingParams: [
          ItemSortParameter(
              active: true,
              type: ItemSortParameterType.PowerLevel,
              direction: -1)
        ]));
    var weaponSlots = [
      InventoryBucket.kineticWeapons,
      InventoryBucket.energyWeapons,
      InventoryBucket.powerWeapons
    ];
    var armorSlots = [
      InventoryBucket.helmet,
      InventoryBucket.gauntlets,
      InventoryBucket.chestArmor,
      InventoryBucket.legArmor,
      InventoryBucket.classArmor
    ];
    var validSlots = weaponSlots + armorSlots;
    var equipment =
        widget.profile.getCharacterEquipment(widget.character.characterId);
    var availableSlots = equipment
        .where((i) => validSlots.contains(i.bucketHash))
        .map((i) => i.bucketHash);
    Map<int, DestinyItemComponent> maxLightLoadout = Map();
    Map<int, DestinyItemComponent> maxLightExotics = Map();
    for (var item in instancedItems) {
      var def = await widget.manifest
          .getDefinition<DestinyInventoryItemDefinition>(item.itemHash);
      if (maxLightLoadout.containsKey(def?.inventory?.bucketTypeHash) ||
          !availableSlots.contains(def?.inventory?.bucketTypeHash) ||
          ![widget.character.classType, DestinyClass.Unknown]
              .contains(def?.classType)) {
        continue;
      }
      if (def?.inventory?.tierType == TierType.Exotic &&
          !maxLightExotics.containsKey(def?.inventory?.bucketTypeHash)) {
        maxLightExotics[def?.inventory?.bucketTypeHash] = item;
        continue;
      }

      maxLightLoadout[def?.inventory?.bucketTypeHash] = item;

      if (maxLightLoadout.values.length >= availableSlots.length) {
        break;
      }
    }
    Map<int, DestinyItemComponent> weapons = Map();
    Map<int, DestinyItemComponent> armor = Map();

    weaponSlots.forEach((s) {
      if (maxLightLoadout.containsKey(s)) weapons[s] = maxLightLoadout[s];
    });
    armorSlots.forEach((s) {
      if (maxLightLoadout.containsKey(s)) armor[s] = maxLightLoadout[s];
    });

    List<Map<int, DestinyItemComponent>> weaponAlternatives = [weapons];
    List<Map<int, DestinyItemComponent>> armorAlternatives = [armor];

    maxLightExotics.forEach((bucket, item) {
      if (weaponSlots.contains(bucket)) {
        var exoticLoadout = Map<int, DestinyItemComponent>.from(weapons);
        exoticLoadout[bucket] = item;
        weaponAlternatives.add(exoticLoadout);
      }
      if (armorSlots.contains(bucket)) {
        var exoticLoadout = Map<int, DestinyItemComponent>.from(armor);
        exoticLoadout[bucket] = item;
        armorAlternatives.add(exoticLoadout);
      }
    });

    weaponAlternatives.sort((a, b) {
      var lightA = _getAvgLight(a.values);
      var lightB = _getAvgLight(b.values);
      return lightB.compareTo(lightA);
    });

    armorAlternatives.sort((a, b) {
      var lightA = _getAvgLight(a.values);
      var lightB = _getAvgLight(b.values);
      return lightB.compareTo(lightA);
    });

    weaponAlternatives.first.forEach((bucket, item){
      maxLightLoadout[bucket] = item;
    });
    armorAlternatives.first.forEach((bucket, item){
      maxLightLoadout[bucket] = item;
    });

    maxLight = _getAvgLight(maxLightLoadout.values);
    this.maxLightLoadout = maxLightLoadout;
    setState(() {});
  }

  double _getAvgLight(Iterable<DestinyItemComponent> items) {
    var total = items.fold(
        0,
        (light, item) =>
            light +
                widget.profile
                    .getInstanceInfo(item.itemInstanceId)
                    ?.primaryStat
                    ?.value ??
            0);
    return total / items.length;
  }
}
