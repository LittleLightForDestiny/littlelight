import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/item_category.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:tinycolor/tinycolor.dart';
typedef void OnSelect(categoryHash);
class ItemTypeMenuWidget extends StatelessWidget {
  final int currentGroup;
  final OnSelect onSelect;

  const ItemTypeMenuWidget(this.currentGroup, {Key key, this.onSelect}) : super(key: key); 
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: getButtons(),
            )));
  }

  List<Widget> getButtons() {
    return [
      ItemCategory.weapon,
      ItemCategory.armor,
      ItemCategory.inventory].map<Widget>((hash){
        return Expanded(child:ItemTypeMenuButton(hash, hash == currentGroup,
        onSelect: onSelect));
      }).toList();
  }
}
class ItemTypeMenuButton extends StatelessWidget {
  final ManifestService manifest = new ManifestService();
  final int categoryHash;
  final bool selected;
  final OnSelect onSelect;

  ItemTypeMenuButton(this.categoryHash, this.selected, {this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (){
            if(onSelect != null){
              onSelect(this.categoryHash);
            }
          },
          child: 
          Container(
            decoration: selected ? BoxDecoration(border: BorderDirectional(
              top:BorderSide(color: Colors.white, width: 4),
            )) : null,
            alignment: AlignmentDirectional.center,
            child:ManifestText<DestinyItemCategoryDefinition>(
            categoryHash,
            style: TextStyle(fontWeight: FontWeight.w700)),
        )));
          
  }
}
