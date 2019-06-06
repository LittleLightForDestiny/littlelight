import 'package:drag_list/drag_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/header.wiget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/smaller_switch.dart';
import 'package:screen/screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserSettingsService settings = new UserSettingsService();
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<SortParameter> itemOrdering;

  @override
  void initState() {
    super.initState();
    itemOrdering = widget.settings.itemOrdering;
  }

  @override
  Widget build(BuildContext context) {
    TranslatedTextWidget("Order characters by");
    TranslatedTextWidget("Last played");
    TranslatedTextWidget("Creation date");
    TranslatedTextWidget("Custom");
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: TranslatedTextWidget("Settings"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[
              ListTile(
                  title: TranslatedTextWidget(
                    "Keep Awake",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: TranslatedTextWidget(
                      "Keep device awake while the app is open"),
                  trailing: Switch(
                    value: widget.settings.keepAwake,
                    onChanged: (val) {
                      widget.settings.keepAwake = val;
                      setState(() {});
                      Screen.keepOn(val);
                    },
                  )),
              Container(height: 16),
              HeaderWidget(
                  alignment: Alignment.centerLeft,
                  child: TranslatedTextWidget(
                    "Order items by",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              buildItemOrderList(context)
            ])));
  }

  buildItemOrderList(BuildContext context) {
    return Container(
        height: (itemOrdering.length + 1) * 48.0,
        child: DragList<SortParameter>(
          items: itemOrdering,
          itemExtent: 48,
          handleBuilder: (context) => AspectRatio(
              aspectRatio: 1, child: Container(child: Icon(Icons.menu))),
          onItemReorder: (oldIndex, newIndex) {
            var removed = itemOrdering.removeAt(oldIndex);
            itemOrdering.insert(newIndex, removed);
            widget.settings.itemOrdering = itemOrdering;
          },
          builder: (context, parameter, handle) =>
              buildSortItem(context, parameter, handle),
        ));
  }

  Widget buildSortItem(
      BuildContext context, SortParameter parameter, Widget handle) {
    return Container(
        key: Key("param_${parameter.type}"),
        child: Container(
            color: parameter.active
                ? Colors.blueGrey.shade700
                : Colors.blueGrey.shade800,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              handle,
              Container(width: 8),
              Expanded(child: buildSortLabel(parameter)),
              buildDirectionButton(parameter, 1),
              Container(width: 4),
              buildDirectionButton(parameter, -1),
              Container(width: 8),
              Container(
                  padding: EdgeInsets.all(8),
                  child: SmallerSwitch(
                    onChanged: (value) {
                      parameter.active = value;
                      widget.settings.itemOrdering = itemOrdering;
                      setState(() {});
                    },
                    value: parameter.active,
                  ))
            ])));
  }

  Widget buildDirectionButton(SortParameter parameter, int direction) {
    var selected = parameter.direction == direction;
    if(!parameter.active) return Container();
    return Container(
      width: 20,
      height: 20,
      child: RaisedButton(
          color: selected ? Colors.lightBlue : Colors.blueGrey,
          padding: EdgeInsets.all(0),
          child: Icon(
              direction > 0
                  ? FontAwesomeIcons.chevronUp
                  : FontAwesomeIcons.chevronDown,
              size: 14),
          onPressed: () {
            parameter.direction = direction;
            setState(() {});
            widget.settings.itemOrdering = itemOrdering;
          }),
    );
  }

  Widget buildSortLabel(SortParameter parameter) {
    var style = TextStyle(
        fontWeight: FontWeight.bold,
        color: parameter.active ? Colors.white : Colors.grey.shade500);
    switch (parameter.type) {
      case SortParameterType.PowerLevel:
        return TranslatedTextWidget(
          "Power Level",
          uppercase: true,
          style: style,
        );

      case SortParameterType.TierType:
        return TranslatedTextWidget(
          "Rarity",
          uppercase: true,
          style: style,
        );
      case SortParameterType.Name:
        return TranslatedTextWidget(
          "Name",
          uppercase: true,
          style: style,
        );
      case SortParameterType.SubType:
        return TranslatedTextWidget(
          "Type",
          uppercase: true,
          style: style,
        );
      case SortParameterType.ClassType:
        return TranslatedTextWidget(
          "Class Type",
          uppercase: true,
          style: style,
        );
      case SortParameterType.AmmoType:
        return TranslatedTextWidget(
          "Ammo Type",
          uppercase: true,
          style: style,
        );
      case SortParameterType.BucketHash:
        return TranslatedTextWidget(
          "Slot",
          uppercase: true,
          style: style,
        );
      case SortParameterType.Quantity:
        return TranslatedTextWidget(
          "Quantity",
          uppercase: true,
          style: style,
        );
      default:
        return Text(
          "oops",
          style: style,
        );
    }
  }
}
