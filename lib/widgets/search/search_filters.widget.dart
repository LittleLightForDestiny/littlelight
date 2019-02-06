import 'package:flutter/material.dart';
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
  const SearchFiltersWidget({Key key, this.filterData}) : super(key: key);
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

    return Column(children: controls);
  }

  Widget buildPowerLevel(BuildContext context, FilterItem data) {
    double lower = data.values[0].toDouble();
    double upper = data.values[1].toDouble();
    double min = data.options[0].toDouble();
    double max = data.options[1].toDouble();
    return ExpansionTile(
      backgroundColor: Colors.blueGrey.shade900,
      title: TranslatedTextWidget("Power Level"),
      children: <Widget>[
        Stack(children: [
          Positioned(
              left:0,
              width: 50,
              child: Text("${lower.toInt()}", textAlign: TextAlign.center,)),
          Positioned.fill(
            left:0, right:0,
            child:Container(
              child: RangeSlider(
                  min: min,
                  max: max,
                  lowerValue: lower,
                  upperValue: upper,
                  onChanged: (lower, upper) {
                    data.values[0] = lower.toInt();
                    data.values[1] = upper.toInt();
                    setState(() {});
                  }))),
          Positioned(
              right:0,
              width: 50,
              child: Text("${upper.toInt()}", textAlign: TextAlign.center,)),
        ])
      ],
    );
  }
}
