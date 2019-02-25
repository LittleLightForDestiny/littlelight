import 'package:bungie_api/enums/destiny_class_enum.dart';
import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/enums/tier_type_enum.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/edit_loadout.screen.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/littlelight/littlelight.service.dart';
import 'package:little_light/services/littlelight/models/loadout.model.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/destiny_icons_icons.dart';
import 'package:shimmer/shimmer.dart';

class CharacterInfoWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final String characterId;
  CharacterInfoWidget({this.characterId, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CharacterInfoWidgetState();
  }
}

class CharacterInfoWidgetState extends State<CharacterInfoWidget> {
  DestinyClassDefinition classDef;
  DestinyRaceDefinition raceDef;
  DestinyCharacterComponent character;

  @override
  void initState() {
    character = widget.profile.getCharacter(widget.characterId);
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    classDef = await widget.manifest.getClassDefinition(character.classHash);
    raceDef = await widget.manifest.getRaceDefinition(character.raceHash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      mainCharacterInfo(context, character),
      characterStatsInfo(context, character),
      ghostIcon(context),
      expInfo(context, character),
      Positioned.fill(
          child: FlatButton(
              child: Container(),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return CharacterOptionsSheet(
                        character: character,
                      );
                    });
              }))
    ]);
  }

  Widget ghostIcon(BuildContext context) {
    return Positioned.fill(
        child: Container(
            width: 50,
            height: 50,
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade400,
                highlightColor: Colors.grey.shade100,
                period: Duration(seconds: 5),
                child: Icon(DestinyIcons.ghost,
                    size: 50, color: Colors.grey.shade300))));
  }

  Widget characterStatsInfo(
      BuildContext context, DestinyCharacterComponent character) {
    return Positioned(
        right: 8,
        top: 24,
        bottom: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(
                      DestinyIcons.power,
                      color: Colors.amber.shade500,
                      size: 16,
                    )),
                Text(
                  "${character.light}",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 34,
                      color: Colors.amber.shade500),
                )
              ],
            ),
            TranslatedTextWidget("Level {Level}",
                replace: {
                  'Level': "${character.levelProgression.level}",
                },
                style: TextStyle(fontSize: 12))
          ],
        ));
  }

  Widget mainCharacterInfo(
      BuildContext context, DestinyCharacterComponent character) {
    if (classDef == null || raceDef == null) {
      return Container();
    }
    String genderType = character.genderType == 0 ? "Male" : "Female";
    return Positioned(
        top: 24,
        left: 8,
        bottom: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(classDef.genderedClassNames[genderType].toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            Text(
              raceDef.genderedRaceNames[genderType],
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
            ),
            characterStats(context, character)
          ],
        ));
  }

  Widget characterStats(
      BuildContext context, DestinyCharacterComponent character) {
    List<Widget> stats = [];
    character.stats.forEach((hash, stat) {
      if (hash == "${ProgressionHash.Power}") return;
      stats.add(Container(
          width: 16,
          height: 16,
          child: ManifestImageWidget<DestinyStatDefinition>(
            int.parse(hash),
            placeholder: Container(),
          )));
      stats.add(Text(
        "$stat",
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ));
      stats.add(Container(width: 4));
    });
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: stats);
  }

  Widget expInfo(BuildContext context, DestinyCharacterComponent character) {
    DestinyProgression levelProg = character.levelProgression;
    bool isMaxLevel = levelProg.level >= levelProg.levelCap;
    if (isMaxLevel) {
      levelProg = widget.profile
          .getCharacterProgression(character.characterId)
          .progressions[ProgressionHash.Overlevel];
    }

    return Positioned(
        right: 8,
        top: 4,
        child: Text(
          "${levelProg.progressToNextLevel}/${levelProg.nextLevelAt}",
          style: TextStyle(
              color: Colors.grey.shade300,
              fontSize: 11,
              fontWeight: FontWeight.bold),
        ));
  }
}

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

  @override
  void initState() {
    super.initState();
    getItemsInPostmaster();
    getMaxLightLoadout();
    getLoadouts();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              RaisedButton(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TranslatedTextWidget("Equip Max Light"),
                      maxLight == null
                          ? Container(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator())
                          : Text(
                              "${maxLight?.toStringAsFixed(1) ?? ""}",
                              style: TextStyle(color: Colors.amber.shade300),
                            )
                    ]),
                onPressed: maxLight == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        InventoryService().transferLoadout(
                            maxLightLoadout.loadout,
                            widget.character.characterId,
                            true);
                      },
              ),
              RaisedButton(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TranslatedTextWidget("Create Loadout"),
                      TranslatedTextWidget("Equipped")
                    ]),
                onPressed: () async {
                  var itemIndex = await createLoadout();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => EditLoadoutScreen(
                            loadout: itemIndex.loadout,
                            forceCreate: true,
                          )));
                },
              ),
              RaisedButton(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TranslatedTextWidget("Create Loadout"),
                      TranslatedTextWidget("All")
                    ]),
                onPressed: () async {
                  var itemIndex = await createLoadout(true);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => EditLoadoutScreen(
                            loadout: itemIndex.loadout,
                            forceCreate: true,
                          )));
                },
              ),
              (loadouts?.length ?? 0) > 0
                  ? RaisedButton(
                      child: TranslatedTextWidget("Equip Loadout"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet(
                            context: context, builder: buildLoadoutListModal);
                      },
                    )
                  : Container(),
              (itemsInPostmaster?.length ?? 0) > 0
                  ? RaisedButton(
                      child: TranslatedTextWidget(
                          "Pull everything from postmaster"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        InventoryService().transferMultiple(
                            itemsInPostmaster
                                .map((i) => ItemInventoryState(
                                    widget.character.characterId, i))
                                .toList(),
                            ItemDestination.Character,
                            widget.character.characterId);
                      },
                    )
                  : Container(),
              RaisedButton(
                child: TranslatedTextWidget("Force refresh"),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.profile.fetchProfileData();
                },
              )
            ]));
  }

  Widget buildLoadoutListModal(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: loadouts
                  .map(
                    (loadout) => Container(
                        color: Theme.of(context).buttonColor,
                        margin:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Stack(children: [
                          Positioned.fill(
                              child: loadout.emblemHash != null
                                  ? ManifestImageWidget<
                                      DestinyInventoryItemDefinition>(
                                      loadout.emblemHash,
                                      fit: BoxFit.cover,
                                      urlExtractor: (def) {
                                        return def?.secondarySpecial;
                                      },
                                    )
                                  : Container()),
                          Container(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                loadout.name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Positioned.fill(
                              child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                InventoryService().transferLoadout(loadout,
                                    widget.character.characterId, true);
                              },
                            ),
                          ))
                        ])),
                  )
                  .toList(),
            )));
  }

  Future<LoadoutItemIndex> createLoadout([includeUnequipped = false]) async {
    var itemIndex = new LoadoutItemIndex();
    var slots = LoadoutItemIndex.classBucketHashes +
        LoadoutItemIndex.genericBucketHashes;
    var equipment =
        widget.profile.getCharacterEquipment(widget.character.characterId);
    var equipped = equipment.where((i) => slots.contains(i.bucketHash));
    for (var item in equipped) {
      var def = await widget.manifest.getItemDefinition(item.itemHash);
      itemIndex.addEquippedItem(item, def);
    }
    if (!includeUnequipped) return itemIndex;
    var inventory =
        widget.profile.getCharacterInventory(widget.character.characterId);
    var unequipped = inventory.where((i) => slots.contains(i.bucketHash));
    for (var item in unequipped) {
      var def = await widget.manifest.getItemDefinition(item.itemHash);
      itemIndex.addUnequippedItem(item, def);
    }
    return itemIndex;
  }

  getMaxLightLoadout() async {
    var allItems = widget.profile.getAllItems();
    var instancedItems =
        allItems.where((i) => i.itemInstanceId != null).toList();
    instancedItems.sort((itemA, itemB) =>
        InventoryUtils.sortDestinyItems(itemA, itemB, widget.profile));
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
      var def = await widget.manifest.getItemDefinition(exoticWeapon.itemHash);
      maxLightLoadout.addEquippedItem(exoticWeapon, def);
    }

    if (exoticArmor != null) {
      var def = await widget.manifest.getItemDefinition(exoticArmor.itemHash);
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

  bool isLoadoutComplete(LoadoutItemIndex index) {
    return false;
  }

  debugLoadout(LoadoutItemIndex loadout) async {
    var isInDebug = false;
    assert(isInDebug = true);
    if (!isInDebug) return;
    for (var item in loadout.generic.values) {
      if (item == null) continue;
      var def = await widget.manifest.getItemDefinition(item.itemHash);
      var bucket = await widget.manifest
          .getBucketDefinition(def.inventory.bucketTypeHash);
      var instance = widget.profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
    for (var items in loadout.classSpecific.values) {
      var item = items[widget.character.classType];
      if (item == null) continue;
      var def = await widget.manifest.getItemDefinition(item.itemHash);
      var bucket = await widget.manifest
          .getBucketDefinition(def.inventory.bucketTypeHash);
      var instance = widget.profile.getInstanceInfo(item.itemInstanceId);
      print("---------------------------------------------------------------");
      print(bucket.displayProperties.name);
      print("---------------------------------------------------------------");
      print("${def.displayProperties.name} ${instance?.primaryStat?.value}");
      print("---------------------------------------------------------------");
    }
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
}
