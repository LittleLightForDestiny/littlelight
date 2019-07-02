import 'package:flutter/material.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as range;
import 'package:bungie_api/models/destiny_item_tier_type_definition.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';

enum FilterType {
  powerLevel,
  damageType,
  bucketType,
  tierType,
  itemType,
  itemSubType,
  ammoType,
  classType,
}

class FilterItem {
  List<int> options;
  List<int> values;
  bool open;

  FilterItem(this.options, this.values, {this.open = false});
}



class SearchFiltersWidget extends StatefulWidget {
  final Map<FilterType, FilterItem> filterData;
  final Function onChange;
  const SearchFiltersWidget({Key key, this.filterData, this.onChange})
      : super(key: key);
  @override
  SearchFiltersWidgetState createState() => new SearchFiltersWidgetState();
}

class SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  FilterType multiselect;
  @override
  initState() {
    super.initState();
  }

  loadItems() async {}

  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: [
        AppBar(
          title: TranslatedTextWidget("Filters"),
          automaticallyImplyLeading: false,
          actions: <Widget>[Container()],
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(child: ListView(children: buildControls(context)))
      ],
    ));
  }

  List<Widget> buildControls(BuildContext context) {
    List<Widget> controls = [];
    if (widget.filterData.containsKey(FilterType.powerLevel)) {
      controls.add(
          buildPowerLevel(context, widget.filterData[FilterType.powerLevel]));
      controls.add(Container(height: 10));
    }
    if (widget.filterData.containsKey(FilterType.damageType)) {
      controls.add(buildTypeSelector(
          context, TranslatedTextWidget("Damage Type"), FilterType.damageType));
      controls.add(Container(height: 10));
    }

    if (widget.filterData.containsKey(FilterType.classType)) {
      controls.add(buildTypeSelector(
          context, TranslatedTextWidget("Class"), FilterType.classType));
      controls.add(Container(height: 10));
    }

    if (widget.filterData.containsKey(FilterType.bucketType)) {
      controls.add(buildTypeSelector(
          context, TranslatedTextWidget("Slot"), FilterType.bucketType));
      controls.add(Container(height: 10));
    }

    if (widget.filterData.containsKey(FilterType.tierType)) {
      controls.add(buildTypeSelector(
          context, TranslatedTextWidget("Tier Type"), FilterType.tierType));
      controls.add(Container(height: 10));
    }

    if (widget.filterData.containsKey(FilterType.itemType)) {
      controls.add(buildTypeSelector(
          context, TranslatedTextWidget("Type"), FilterType.itemType));
      controls.add(Container(height: 10));
    }

    if (widget.filterData.containsKey(FilterType.itemSubType)) {
      controls.add(buildTypeSelector(
          context, TranslatedTextWidget("Type"), FilterType.itemSubType));
      controls.add(Container(height: 10));
    }

    if (widget.filterData.containsKey(FilterType.ammoType)) {
      controls.add(buildTypeSelector(
          context, TranslatedTextWidget("Ammo Type"), FilterType.ammoType));
      controls.add(Container(height: 10));
    }
    return controls;
  }

  Widget buildPowerLevel(BuildContext context, FilterItem data) {
    double lower = data.values[0].toDouble();
    double upper = data.values[1].toDouble();
    double min = data.options[0].toDouble();
    double max = data.options[1].toDouble();
    return Container(
        color: Colors.blueGrey.shade500,
        child: ExpansionTile(
          initiallyExpanded: data.open,
          onExpansionChanged: (value) {
            data.open = value;
          },
          backgroundColor: Colors.blueGrey.shade900,
          title: TranslatedTextWidget("Power Level"),
          children: <Widget>[
            Container(
                height: 50,
                child: Stack(alignment: Alignment.center, children: [
                  Positioned(
                      left: 0,
                      width: 40,
                      child: Text(
                        "${lower.toInt()}",
                        textAlign: TextAlign.right,
                      )),
                  Positioned.fill(
                      left: 40,
                      right: 40,
                      child: range.RangeSlider(
                        touchRadiusExpansionRatio: 6,
                        min: min,
                        max: max,
                        lowerValue: lower,
                        upperValue: upper,
                        onChanged: (lower, upper) {
                          data.values[0] = lower.toInt();
                          data.values[1] = upper.toInt();
                          setState(() {});
                        },
                        onChangeEnd: (lower, upper) {
                          widget.onChange();
                        },
                      )),
                  Positioned(
                      right: 0,
                      width: 40,
                      child: Text(
                        "${upper.toInt()}",
                        textAlign: TextAlign.left,
                      )),
                ]))
          ],
        ));
  }

  Widget buildTypeSelector<T>(
      BuildContext context, Widget title, FilterType type) {
    var data = widget.filterData[type];

    List<Widget> chips =
        data.options.map((i) => optionButton(context, i, type)).toList();
    return Container(
        color: Colors.blueGrey.shade500,
        child: ExpansionTile(
            onExpansionChanged: (value) {
              data.open = value;
            },
            initiallyExpanded: data.open,
            backgroundColor: Colors.blueGrey.shade900,
            title: title,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: button(
                      context,
                      TranslatedTextWidget(
                        "All",
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      data.values.length == 0, onTap: () {
                    data.values.clear();
                    multiselect = null;
                    widget.onChange();
                  })),
              Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6).copyWith(bottom: 8),
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: chips,
                  ))
            ]));
  }

  Widget optionButton(BuildContext context, int id, FilterType type) {
    var filter = widget.filterData[type];
    var onTap = () {
      if (multiselect == type) {
        if (filter.values.contains(id)) {
          filter.values.remove(id);
          if (filter.values.length <= 1) {
            multiselect = null;
          }
        } else {
          filter.values.add(id);
        }
      } else {
        filter.values.clear();
        filter.values.add(id);
        multiselect = null;
      }
      widget.onChange();
    };

    var onLongPress = () {
      multiselect = type;
      filter.values.add(id);
      widget.onChange();
    };
    switch (type) {
      case FilterType.damageType:
        return FractionallySizedBox(
            widthFactor: 1 / 4,
            child: AspectRatio(
                aspectRatio: 1.5,
                child: button(
                    context,
                    Icon(
                      DestinyData.getDamageTypeIcon(id),
                      color: DestinyData.getDamageTypeTextColor(id),
                    ),
                    filter.values.contains(id),
                    onTap: onTap,
                    onLongPress: onLongPress)));

      case FilterType.ammoType:
        return FractionallySizedBox(
            widthFactor: 1 / 3,
            child: AspectRatio(
                aspectRatio: 2,
                child: button(
                    context,
                    Icon(
                      DestinyData.getAmmoTypeIcon(id),
                      size: 30,
                      color: DestinyData.getAmmoTypeColor(id),
                    ),
                    filter.values.contains(id),
                    onTap: onTap,
                    onLongPress: onLongPress)));

      case FilterType.classType:
        return FractionallySizedBox(
            widthFactor: 1 / 3,
            child: AspectRatio(
                aspectRatio: 2,
                child: button(
                    context,
                    Icon(
                      DestinyData.getClassIcon(id),
                      size: 30,
                    ),
                    filter.values.contains(id),
                    onTap: onTap,
                    onLongPress: onLongPress)));

      case FilterType.tierType:
        return FractionallySizedBox(
            widthFactor: 1 / 3,
            child: button(
                context,
                ManifestText<DestinyItemTierTypeDefinition>(
                    DestinyData.tierTypeHashes[id],
                    uppercase: true,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: DestinyData.getTierTextColor(id),
                    )),
                filter.values.contains(id),
                color: DestinyData.getTierColor(id),
                onTap: onTap,
                onLongPress: onLongPress));

      case FilterType.bucketType:
        return button(
            context,
            ManifestText<DestinyInventoryBucketDefinition>(id,
                uppercase: true,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            filter.values.contains(id),
            onTap: onTap,
            onLongPress: onLongPress);

      case FilterType.itemType:
        return FractionallySizedBox(
            widthFactor: 1 / 2,
            child: AspectRatio(
                aspectRatio: 3,
                child: button(
                    context,
                    ManifestText<DestinyItemCategoryDefinition>(
                        DestinyData.itemTypeHashes[id],
                        uppercase: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                    filter.values.contains(id),
                    onTap: onTap,
                    onLongPress: onLongPress)));

      case FilterType.itemSubType:
        return FractionallySizedBox(
            widthFactor: 1 / 2,
            child: AspectRatio(
                aspectRatio: 3,
                child: button(
                    context,
                    ManifestText<DestinyItemCategoryDefinition>(
                        DestinyData.itemSubtypeHashes[id],
                        uppercase: true,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        )),
                    filter.values.contains(id),
                    onTap: onTap,
                    onLongPress: onLongPress)));

      default:
        break;
    }
    return Container();
  }

  Widget button(BuildContext context, Widget content, bool selected,
      {Color color, Function onTap, Function onLongPress}) {
    return Container(
        margin: EdgeInsets.all(2),
        child: Material(
            borderRadius: BorderRadius.circular(4),
            color: selected
                ? Colors.lightBlue.shade700
                : color ?? Colors.blueGrey.shade800,
            child: InkWell(
                enableFeedback: false,
                onTap: onTap,
                onLongPress: onLongPress,
                child: Container(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(4),
                    child: content))));
  }
}
