import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/widgets/item_list/items/armor/armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/medium_armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/minimal_armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/emblem/emblem_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/emblem/medium_emblem_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/empty_inventory_item_widget.dart';
import 'package:little_light/widgets/item_list/items/engram/empty_engram_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/engram/minimal_engram_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/medium_subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/medium_weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/minimal_weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_inventory_item.widget.dart';
import 'package:uuid/uuid.dart';

enum ContentDensity { MINIMAL, MEDIUM, FULL }

class InventoryItemWrapperWidget extends StatefulWidget {
  final ManifestService manifest = ManifestService();
  final ProfileService profile = ProfileService();
  final DestinyItemComponent item;
  final String characterId;
  final ContentDensity density;
  final int bucketHash;
  InventoryItemWrapperWidget(this.item, this.bucketHash,
      {Key key, @required this.characterId, this.density = ContentDensity.FULL})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InventoryItemWrapperWidgetState();
  }
}

class InventoryItemWrapperWidgetState<T extends InventoryItemWrapperWidget>
    extends State<InventoryItemWrapperWidget> {
  DestinyInventoryItemDefinition definition;
  String uniqueId;
  bool get selected =>SelectionService().isSelected(widget.item, widget.characterId);

  DestinyItemInstanceComponent get instanceInfo {
    return widget.profile.getInstanceInfo(widget.item.itemInstanceId);
  }

  static int queueSize = 0;

  @override
  void initState() {
    uniqueId = Uuid().v4();
    if (isLoaded) {
      this.definition = widget.manifest
          .getDefinitionFromCache<DestinyInventoryItemDefinition>(
              widget.item.itemHash);
    }
    super.initState();
    if (widget.item != null && !isLoaded) {
      getDefinitions();
    }
  }

  bool get isLoaded {
    if (widget.item == null) {
      return false;
    }
    return widget.manifest
        .isLoaded<DestinyInventoryItemDefinition>(widget.item.itemHash);
  }

  getDefinitions() async {
    queueSize++;
    if (queueSize > 1) {
      await Future.delayed(Duration(milliseconds: 100 * queueSize));
      if (!mounted) {
        queueSize--;
        return;
      }
    }
    definition =
        await widget.manifest.getItemDefinition(widget.item.itemHash);
    if (mounted) {
      setState(() {});
    }
    queueSize--;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: buildItem(context)),
      selected ? Container(foregroundDecoration: BoxDecoration(border:Border.all(color:Colors.lightBlue.shade400, width:2)),) : Container(),
      buildTapHandler(context)
    ]);
  }

  Widget buildTapHandler(BuildContext context) {
    if (widget.item == null) {
      return Container();
    }
    return Positioned.fill(child: Material(
      color:Colors.transparent,
      child: InkWell(
      onTap: () {
        onTap(context);
      },
      onLongPress: (){
        onLongPress(context);
      },
    )));
  }

  void onLongPress(context){
    if(definition.nonTransferrable) return;
    
    SelectionService().addItem(widget.item, widget.characterId);
    setState((){});
    
    StreamSubscription<List<ItemInventoryState>> sub;
    sub = SelectionService().broadcaster.listen((selectedItems){
      if(!mounted){
        sub.cancel();
        return;
      }
      setState(() {});
      if(!selected){
        sub.cancel();
      }
    });
  }

  void onTap(context) {
    if(SelectionService().multiselectActivated){
      onLongPress(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
              widget.item,
              definition,
              instanceInfo,
              characterId: widget.characterId,
              uniqueId: uniqueId,
            ),
      ),
    );
  }

  Widget buildItem(BuildContext context) {
    if (widget.item == null) {
      return buildEmpty(context);
    }
    if (definition == null) {
      return Container();
    }

    switch (widget.density) {
      case ContentDensity.MINIMAL:
        return buildMinimal(context);

      case ContentDensity.MEDIUM:
        return buildMedium(context);

      case ContentDensity.FULL:
        return buildFull(context);
    }

    return BaseInventoryItemWidget(
      widget.item,
      definition,
      instanceInfo,
      characterId: widget.characterId,
      uniqueId: uniqueId,
    );
  }

  Widget buildEmpty(BuildContext context) {
    switch (widget.bucketHash) {
      case InventoryBucket.engrams:
        {
          return EmptyEngramInventoryItemWidget(uniqueId: uniqueId);
        }
      default:
        {
          return EmptyInventoryItemWidget();
        }
    }
  }

  Widget buildMinimal(BuildContext context) {
    switch (definition.itemType) {
      case ItemType.armor:
        {
          return MinimalArmorInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case ItemType.weapon:
        {
          return MinimalWeaponInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case ItemType.engrams:
        {
          return MinimalEngramInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      default:
        return MinimalBaseInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }

  Widget buildMedium(BuildContext context) {
    switch (definition.itemType) {
      case ItemType.subclasses:
        {
          return MediumSubclassInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      case ItemType.weapon:
        {
          return MediumWeaponInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case ItemType.armor:
        {
          return MediumArmorInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case ItemType.emblems:{
          return MediumEmblemInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
      }
      
      default:
        return MediumBaseInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }

  Widget buildFull(BuildContext context) {
    switch (definition.itemType) {
      case ItemType.subclasses:
        {
          return SubclassInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      case ItemType.weapon:
        {
          return WeaponInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case ItemType.armor:
        {
          return ArmorInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case ItemType.emblems:{
        return EmblemInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );

      }
      default:
        return BaseInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }
}
