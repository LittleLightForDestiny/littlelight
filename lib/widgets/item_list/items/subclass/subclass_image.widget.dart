import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/destiny_utils/subclass_talentgrid_info.dart';
import 'package:little_light/widgets/common/destiny_item.stateful_widget.dart';

class SubClassImageWidget extends DestinyItemStatefulWidget {
  SubClassImageWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo)
      : super(item, definition, instanceInfo);

  @override
  _SubClassImageWidgetState createState() => _SubClassImageWidgetState();
}

class _SubClassImageWidgetState extends DestinyItemState<SubClassImageWidget> {
  String imagePath;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    getDefinitions();
  }

  getDefinitions() async {
    var talentGridDef = await widget.manifest
        .getDefinition<DestinyTalentGridDefinition>(
            definition.talentGrid.talentGridHash);
    var talentGrid = widget.profile.getTalentGrid(item?.itemInstanceId);
    var cat = extractTalentGridNodeCategory(talentGridDef, talentGrid);
    var path = DestinyData.getSubclassImagePath(definition.classType,
        definition.talentGrid.hudDamageType, cat?.identifier);
    print("path: $path");
    try {
      await rootBundle.load(path);
      imagePath = path;
    } catch (e) {}
    loaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) {
      return Container(color: Colors.red, width: 50, height: 50);
    }
    if (imagePath != null) {
      return Image.asset(
        imagePath,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topRight,
      );
    }
    return Container(color: Colors.blue, width: 50, height: 50);
  }
}
