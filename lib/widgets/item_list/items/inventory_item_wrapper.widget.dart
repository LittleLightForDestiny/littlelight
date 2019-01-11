import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/bungie_api/enums/item_type.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/item_list/items/armor/armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/medium_armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/minimal_armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/empty_inventory_item_widget.dart';
import 'package:little_light/widgets/item_list/items/engram/empty_engram_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/engram/minimal_engram_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/medium_subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/medium_weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/minimal_weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_inventory_item.widget.dart';

enum ContentDensity { MINIMAL, MEDIUM, FULL }

class InventoryItemWrapperWidget extends StatefulWidget {
  final ManifestService _manifest = ManifestService();
  final ProfileService _profile = ProfileService();
  final DestinyItemComponent item;
  final String characterId;
  final ContentDensity density;
  final int bucketHash;
  InventoryItemWrapperWidget(this.item,
      this.bucketHash,
      {Key key, @required this.characterId, this.density = ContentDensity.FULL})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InventoryItemWrapperWidgetState();
  }
}

class InventoryItemWrapperWidgetState
    extends State<InventoryItemWrapperWidget> {
  DestinyInventoryItemDefinition _definition;
  DestinyItemInstanceComponent _instanceInfo;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      getDefinitions();
    }
  }

  getDefinitions() async {
    _definition =
        await widget._manifest.getItemDefinition(widget.item.itemHash);
    _instanceInfo = widget._profile.getInstanceInfo(widget.item.itemInstanceId);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item == null){
      return buildEmpty(context);
    }
    if (_definition == null) {
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

    return BaseInventoryItemWidget(widget.item, _definition, _instanceInfo, characterId:widget.characterId);
  }

  Widget buildEmpty(BuildContext context){
    switch(widget.bucketHash){
      case InventoryBucket.engrams:{
        return EmptyEngramInventoryItemWidget();
      }
      default:{
        return EmptyInventoryItemWidget();
      }
    }
  }

  Widget buildMinimal(BuildContext context) {
    switch (_definition.itemType) {
      case ItemType.armor:{
        return MinimalArmorInventoryItemWidget(widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
      }

      case ItemType.weapon:{
        return MinimalWeaponInventoryItemWidget(widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
      }

      case ItemType.engrams:{
        return MinimalEngramInventoryItemWidget(widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
      }
      default:
      return MinimalBaseInventoryItemWidget(
          widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
    }
  }

  Widget buildMedium(BuildContext context) {
    switch (_definition.itemType) {
      case ItemType.subclasses:
        {
          return MediumSubclassInventoryItemWidget(
              widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
        }
      case ItemType.weapon:
        {
          return MediumWeaponInventoryItemWidget(
              widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
        }

      case ItemType.armor:
        {
          return MediumArmorInventoryItemWidget(
              widget.item, _definition, _instanceInfo);
        }
      default:
        return MediumBaseInventoryItemWidget(
            widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
    }
  }

  Widget buildFull(BuildContext context) {
    switch (_definition.itemType) {
      case ItemType.subclasses:
        {
          return SubclassInventoryItemWidget(
              widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
        }
      case ItemType.weapon:
        {
          return WeaponInventoryItemWidget(
              widget.item, _definition, _instanceInfo, characterId: widget.characterId,);
        }

      case ItemType.armor:
        {
          return ArmorInventoryItemWidget(
              widget.item, _definition, _instanceInfo);
        }
      default:
        return BaseInventoryItemWidget(widget.item, _definition, _instanceInfo, characterId:widget.characterId);
    }
  }
}
