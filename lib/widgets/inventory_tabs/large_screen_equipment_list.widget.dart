import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/widgets/item_list/item_list.widget.dart';

class LargeScreenEquipmentListWidget extends StatefulWidget {
  final DestinyCharacterComponent character;
  LargeScreenEquipmentListWidget({Key key, this.character}) : super(key: key);
  @override
  LargeScreenEquipmentListWidgetState createState() =>
      new LargeScreenEquipmentListWidgetState();
}

class LargeScreenEquipmentListWidgetState
    extends State<LargeScreenEquipmentListWidget> {
  List<DestinyInventoryBucketDefinition> buckefDefs;

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: kToolbarHeight),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ItemListWidget(
                key: Key("weapons"),
                shrinkWrap: true,
                includeInfoHeader: false,
                fixedSizedEquipmentBuckets: true,
                padding: EdgeInsets.all(8),
                characterId: widget.character.characterId,
                bucketHashes: [
                  InventoryBucket.subclass,
                  InventoryBucket.kineticWeapons,
                  InventoryBucket.energyWeapons,
                  InventoryBucket.powerWeapons,
                  InventoryBucket.ghost,
                ],
              ),
            ),
            Expanded(
                child: ItemListWidget(
              key: Key("armor"),
              shrinkWrap: true,
              includeInfoHeader: false,
              padding: EdgeInsets.all(8),
              characterId: widget.character.characterId,
              bucketHashes: [
                InventoryBucket.helmet,
                InventoryBucket.gauntlets,
                InventoryBucket.chestArmor,
                InventoryBucket.legArmor,
                InventoryBucket.classArmor,
              ],
            )),
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: ItemListWidget(
              key: Key("vehicles"),
              shrinkWrap: true,
              includeInfoHeader: false,
              padding: EdgeInsets.all(8),
              characterId: widget.character.characterId,
              bucketHashes: [
                InventoryBucket.vehicle,
              ],
            )),
            Expanded(
                child: ItemListWidget(
              key: Key("ships"),
              shrinkWrap: true,
              includeInfoHeader: false,
              padding: EdgeInsets.all(8),
              characterId: widget.character.characterId,
              bucketHashes: [
                InventoryBucket.ships,
              ],
            )),
            Expanded(
                child: ItemListWidget(
              key: Key("emblems"),
              shrinkWrap: true,
              includeInfoHeader: false,
              padding: EdgeInsets.all(8),
              characterId: widget.character.characterId,
              bucketHashes: [
                InventoryBucket.emblems,
              ],
            ))
          ],
        ),
        ItemListWidget(
          key: Key("inventory"),
          shrinkWrap: true,
          includeInfoHeader: false,
          padding: EdgeInsets.all(8),
          characterId: widget.character.characterId,
          bucketHashes: [
            InventoryBucket.consumables,
            InventoryBucket.modifications,
            InventoryBucket.shaders,
          ],
        )
      ]),
    );
  }
}
