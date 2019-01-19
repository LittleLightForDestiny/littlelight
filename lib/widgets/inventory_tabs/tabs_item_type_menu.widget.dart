import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:tinycolor/tinycolor.dart';

typedef void OnSelect(categoryHash);

class ItemTypeMenuWidget extends StatelessWidget {
  final TabController controller;
  final List<int> groups;

  ItemTypeMenuWidget(this.groups, {Key key, this.controller})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
        right: 0,
        bottom: 0,
        left: 0,
        height: kBottomNavigationBarHeight + paddingBottom,
        child: Container(
            padding: EdgeInsets.only(bottom: paddingBottom),
            color: TinyColor(Colors.blueGrey.shade900)
                .darken(10)
                .color
                .withOpacity(.9),
            child: TabBar(
              indicator: BoxDecoration(border: Border(top:BorderSide(width: 2, color:Colors.white))),
              controller: controller,
              tabs: getButtons(),
            )));
  }

  List<Widget> getButtons() {
    return groups.map<Widget>((hash) {
      return ItemTypeMenuButton(hash);
    }).toList();
  }
}

class ItemTypeMenuButton extends StatelessWidget {
  final ManifestService manifest = new ManifestService();
  final int categoryHash;

  ItemTypeMenuButton(this.categoryHash);

  @override
  Widget build(BuildContext context) {
    return ManifestText<DestinyItemCategoryDefinition>(categoryHash,
        style: TextStyle(fontWeight: FontWeight.w700));
  }
}
