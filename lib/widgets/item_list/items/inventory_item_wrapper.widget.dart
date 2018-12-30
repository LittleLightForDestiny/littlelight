import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie-api/enums/item-category.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/item_list/items/empty_inventory_item_widget.dart';
import 'package:little_light/widgets/item_list/items/inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/medium_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/medium_subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass_inventory_item.widget.dart';


enum ContentDensity { MINIMUM, MEDIUM, FULL }

class InventoryItemWrapperWidget extends StatefulWidget {
  final ManifestService _manifest = ManifestService();
  final ProfileService _profile = ProfileService();
  final DestinyItemComponent item;
  final ContentDensity density;
  InventoryItemWrapperWidget(this.item, {Key key, this.density = ContentDensity.FULL}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InventoryItemWrapperWidgetState();
  }
}

class InventoryItemWrapperWidgetState extends State<InventoryItemWrapperWidget> {
  DestinyInventoryItemDefinition _definition;
  DestinyItemInstanceComponent _instanceInfo;

  @override
  void initState() {
    super.initState();
    if(_definition == null && widget.item !=null){
      getDefinitions();
    }
  }

  getDefinitions() async {
    _definition =
        await widget._manifest.getItemDefinition(widget.item.itemHash);
    _instanceInfo = widget._profile.getInstanceInfo(widget.item.itemInstanceId);
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item == null) return EmptyInventoryItemWidget();
    if(_definition == null || _instanceInfo == null){
      return Container();
    }
    if (widget.density == ContentDensity.MEDIUM) {
      if (_definition.itemType == ItemCategory.subclasses) {
        return MediumSubclassInventoryItemWidget(widget.item, _definition, _instanceInfo);
      }
      return MediumInventoryItemWidget(widget.item, _definition, _instanceInfo);
    }

    if (_definition.itemType == ItemCategory.subclasses) {
      return SubclassInventoryItemWidget(widget.item, _definition, _instanceInfo);
    }

    return InventoryItemWidget(widget.item, _definition, _instanceInfo);
  }
}
