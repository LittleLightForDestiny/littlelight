import 'package:flutter/material.dart';

typedef OnChangeValues = void Function(RangeValues values);

class FilterRangeSliderWidget extends StatefulWidget {
  final int min;
  final int max;
  final int availableMin;
  final int availableMax;
  final OnChangeValues onChange;
  const FilterRangeSliderWidget({
    Key? key,
    required this.min,
    required this.max,
    required this.availableMin,
    required this.availableMax,
    required this.onChange,
  }) : super(key: key);

  @override
  State<FilterRangeSliderWidget> createState() =>
      _FilterRangeSliderWidgetState();
}

class _FilterRangeSliderWidgetState extends State<FilterRangeSliderWidget> {
  double min = 0;
  double max = 9999;
  double get availableMin => widget.availableMin.toDouble();
  double get availableMax => widget.availableMax.toDouble();
  int get divisions => widget.availableMax - widget.availableMin;

  updateValues() {
    min = widget.min.toDouble();
    max = widget.max.toDouble();
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant FilterRangeSliderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateValues();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateValues();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text("${availableMin.ceil()}"),
          Expanded(
              child: RangeSlider(
            values: RangeValues(min, max),
            min: availableMin,
            max: availableMax,
            divisions: divisions,
            labels: RangeLabels(min.ceil().toString(), max.ceil().toString()),
            onChanged: (values) {
              min = values.start;
              max = values.end;
              setState(() {});
            },
            onChangeEnd: (values) {
              min = values.start;
              max = values.end;
              widget.onChange(values);
            },
          )),
          Text("${availableMax.ceil()}"),
        ],
      ),
    );
  }
}
