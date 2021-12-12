import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/search/search.controller.dart';

class BaseSearchSorterWidget extends StatefulWidget {
  final SearchController controller;
  final ItemSortParameter sortParameter;
  final Widget handle;
  BaseSearchSorterWidget(this.controller, this.sortParameter, {this.handle});

  @override
  BaseSearchSorterWidgetState createState() => BaseSearchSorterWidgetState();
}

class BaseSearchSorterWidgetState<T extends BaseSearchSorterWidget>
    extends State<T> {
  ItemSortParameter get sortParameter => widget.sortParameter;

  SearchController get controller => widget.controller;
  bool multiselectEnabled = false;

  @override
  void initState() {
    super.initState();
    controller?.addListener(onUpdate);
    onUpdate();
  }

  @override
  dispose() {
    controller?.removeListener(onUpdate);
    super.dispose();
  }

  onUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return buildDisabledLabel(context);
  }

  Widget buildDisabledLabel(BuildContext context) {
    return DefaultTextStyle(
        style: TextStyle(fontSize: 14.5),
        child: Container(
            height: 48,
            margin: EdgeInsets.only(top: 8),
            color: Colors.blueGrey.shade600,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: buildButtonContents(context))));
  }

  List<Widget> buildButtonContents(BuildContext context) {
    if (sortParameter.active) {
      return [
        widget.handle ?? Container(),
        Expanded(child: buildSortLabel(context)),
        Container(
          width: 4,
        ),
        buildDirectionButton(1),
        Container(
          width: 4,
        ),
        buildDirectionButton(-1),
        Container(
          width: 4,
        ),
        Container(
            width: 30,
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).errorColor,
                padding: EdgeInsets.all(0),
              ),
              child: Icon(Icons.remove),
              onPressed: () => removeSorter(),
            ))
      ];
    }
    return [
      Expanded(child: buildSortLabel(context)),
      Container(
          width: 30,
          height: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(0),
            ),
            child: Icon(Icons.add),
            onPressed: () => addSorter(context),
          ))
    ];
  }

  Widget buildDirectionButton(int direction) {
    var selected = sortParameter.direction == direction;
    return Container(
      width: 20,
      height: 20,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: selected
                ? Theme.of(context).toggleButtonsTheme.selectedColor
                : Theme.of(context).toggleButtonsTheme.color,
            padding: EdgeInsets.all(0),
          ),
          child: Icon(
              direction > 0
                  ? FontAwesomeIcons.chevronUp
                  : FontAwesomeIcons.chevronDown,
              size: 14),
          onPressed: () {
            if (selected) return;
            sortParameter.direction = direction;
            controller.sort();
          }),
    );
  }

  addSorter(BuildContext context) {
    controller.customSorting.insert(
        0, ItemSortParameter(active: true, type: this.sortParameter.type));
    controller.sort();
  }

  removeSorter() {
    controller.customSorting.remove(this.sortParameter);
    controller.sort();
  }

  Widget buildSortLabel(BuildContext context) {
    var style = TextStyle(
        fontWeight: FontWeight.bold,
        color: sortParameter.active ? Colors.white : Colors.grey.shade300);
    switch (sortParameter.type) {
      case ItemSortParameterType.PowerLevel:
        return TranslatedTextWidget(
          "Power Level",
          uppercase: true,
          style: style,
        );

      case ItemSortParameterType.TierType:
        return TranslatedTextWidget(
          "Rarity",
          uppercase: true,
          style: style,
        );

      case ItemSortParameterType.ExpirationDate:
        return TranslatedTextWidget(
          "Expiration Date",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.Name:
        return TranslatedTextWidget(
          "Name",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.SubType:
        return TranslatedTextWidget(
          "Type",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.ClassType:
        return TranslatedTextWidget(
          "Class Type",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.AmmoType:
        return TranslatedTextWidget(
          "Ammo Type",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.BucketHash:
        return TranslatedTextWidget(
          "Slot",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.Quantity:
        return TranslatedTextWidget(
          "Quantity",
          uppercase: true,
          style: style,
        );

      case ItemSortParameterType.QuestGroup:
        return TranslatedTextWidget("Group", uppercase: true, style: style);

      case ItemSortParameterType.ItemOwner:
        return TranslatedTextWidget("Item Holder",
            uppercase: true, style: style);

      case ItemSortParameterType.StatTotal:
        return TranslatedTextWidget("Stats Total",
            uppercase: true, style: style);

      case ItemSortParameterType.MasterworkStatus:
        return TranslatedTextWidget("Masterwork Status",
            uppercase: true, style: style);
        break;

      case ItemSortParameterType.Stat:
        return TranslatedTextWidget("Stat", uppercase: true, style: style);
        break;

      case ItemSortParameterType.DamageType:
        return TranslatedTextWidget("Damage Type",
            uppercase: true, style: style);
    }
    return Text(
      sortParameter.type.toString(),
      style: style,
    );
  }
}
