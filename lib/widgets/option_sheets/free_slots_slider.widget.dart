// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

typedef FreeSlotsChanged = void Function(int freeSlots);

class FreeSlotsSliderWidget extends StatefulWidget {
  final FreeSlotsChanged onChanged;
  final int initialValue;
  final bool suppressLabel;

  const FreeSlotsSliderWidget({Key key, this.onChanged, this.initialValue = 0, this.suppressLabel = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FreeSlotsSliderWidgetState();
  }
}

class FreeSlotsSliderWidgetState extends State<FreeSlotsSliderWidget> {
  int freeSlots = 0;

  @override
  void initState() {
    super.initState();

    freeSlots = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: <Widget>[
            widget.suppressLabel ? Container() : TranslatedTextWidget("Free Slots"),
            Expanded(
                child: Slider(
              min: 0,
              max: 9,
              value: freeSlots.toDouble(),
              onChanged: (double value) {
                freeSlots = value.round();
                setState(() {});
                if (widget.onChanged != null) {
                  widget.onChanged(freeSlots);
                }
              },
            )),
            Text(
              "$freeSlots",
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ));
  }
}
