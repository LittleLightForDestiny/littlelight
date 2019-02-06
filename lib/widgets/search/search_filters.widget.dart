import 'package:bungie_api/models/destiny_damage_type_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';

enum FilterType {
  powerLevel,
  damageType,
  bucketType,
  tierType,
  itemSubType,
  classType,
}

class FilterItem {
  List<int> options;
  List<int> values;

  FilterItem(this.options, [this.values = const []]);
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
        SingleChildScrollView(child: buildControls(context))
      ],
    ));
  }

  Widget buildControls(BuildContext context) {
    List<Widget> controls = [];
    if (widget.filterData.containsKey(FilterType.powerLevel)) {
      controls.add(
          buildPowerLevel(context, widget.filterData[FilterType.powerLevel]));
    }
    if (widget.filterData.containsKey(FilterType.damageType)) {
      controls.add(buildTypeSelector<DestinyDamageTypeDefinition>(
          context,
          TranslatedTextWidget("Damage Type"),
          widget.filterData[FilterType.damageType]));
    }

    return Column(children: controls);
  }

  Widget buildPowerLevel(BuildContext context, FilterItem data) {
    double lower = data.values[0].toDouble();
    double upper = data.values[1].toDouble();
    double min = data.options[0].toDouble();
    double max = data.options[1].toDouble();
    return Container(
        color: Colors.lightBlue.shade600,
        child: ExpansionTile(
          initiallyExpanded: true,
          backgroundColor: Colors.blueGrey.shade900,
          title: TranslatedTextWidget("Power Level"),
          children: <Widget>[
            Container(
                height: 50,
                child: Stack(alignment: Alignment.center, children: [
                  Positioned(
                      left: 0,
                      width: 50,
                      child: Text(
                        "${lower.toInt()}",
                        textAlign: TextAlign.center,
                      )),
                  Positioned.fill(
                      left: 20,
                      right: 20,
                      child: RangeSlider(
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
                      width: 50,
                      child: Text(
                        "${upper.toInt()}",
                        textAlign: TextAlign.center,
                      )),
                ]))
          ],
        ));
  }

  Widget buildTypeSelector<T>(
      BuildContext context, Widget title, FilterItem data) {
    List<Widget> chips = [];
    chips.add(Container(child: Chip(label: TranslatedTextWidget("All"))));
    chips.addAll(
        data.options.map((i) => Chip(label: ManifestText<T>(i))).toList());
    return Container(
        color: Colors.lightBlue.shade600,
        child: ExpansionTile(
            initiallyExpanded: true,
            backgroundColor: Colors.blueGrey.shade900,
            title: title,
            children: chips));
  }
}
