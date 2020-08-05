import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/base_item_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/smaller_switch.dart';
import 'package:little_light/widgets/search/search.controller.dart';

class BaseSearchFilterWidget<T extends BaseItemFilter> extends StatefulWidget {
  final SearchController controller;
  BaseSearchFilterWidget(this.controller);

  T get filter {
    return [controller.preFilters, controller.filters, controller.postFilters]
        .expand((element) => element)
        .firstWhere((element) => element is T, orElse: () => null);
  }

  @override
  BaseSearchFilterWidgetState createState() => BaseSearchFilterWidgetState();
}

class BaseSearchFilterWidgetState<T extends BaseSearchFilterWidget,
    F extends BaseItemFilter, A> extends State<T> {
  F get filter => widget.filter;

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
    if (!(filter?.available ?? false)) return buildDisabledLabel(context);
    return buildExpansionTile(context);
  }

  Widget buildDisabledLabel(BuildContext context) {
    return DefaultTextStyle(
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14.5),
        child: Container(
            height:58,
            margin: EdgeInsets.only(top: 8),
            color: Colors.blueGrey.shade800,
            padding: EdgeInsets.symmetric(horizontal:16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              buildFilterLabel(context),
              Opacity(
                opacity: .5,
                child:buildDisabledValue(context))
              ])));
  }

  Widget buildDisabledValue(BuildContext context){
    try{
      return buildButtonLabel(context, options.single);
    }catch(_){}
    return TranslatedTextWidget("None", uppercase: true);
  }

  Widget buildExpansionTile(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8),
        color: Colors.blueGrey.shade800,
        child: Theme(
            data: Theme.of(context).copyWith(
                accentColor: Colors.white,
                dividerColor: Colors.blueGrey.shade800),
            child: ExpansionTile(
                trailing: IgnorePointer(
                    child: SmallerSwitch(
                  value: this.filter.enabled,
                  onChanged: (value) {},
                )),
                onExpansionChanged: (value) {
                  this.filter.enabled = value;
                  this.controller.update();
                },
                initiallyExpanded: this.filter.enabled,
                backgroundColor: Colors.blueGrey.shade600,
                title: DefaultTextStyle(
                    child: buildFilterLabel(context),
                    style: TextStyle(fontWeight: FontWeight.w700)),
                children: [
                  Container(
                      constraints: BoxConstraints(minWidth: double.infinity),
                      color: Colors.blueGrey.shade900,
                      padding: EdgeInsets.all(4),
                      child: buildButtons(context))
                ])));
  }

  Iterable<A> get options => filter.availableValues;

  Widget buildFilterLabel(BuildContext context) {
    return Text(this.runtimeType.toString());
  }

  Widget buildButtons(BuildContext context) {
    return Column(
        children: options.map((value) => buildButton(context, value)).toList());
  }

  Widget buildButton(BuildContext context, A value) {
    bool selected = isSelected(value);
    return Container(
        margin: EdgeInsets.all(2),
        decoration: BoxDecoration(
            color: buttonBgColor(value),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: Colors.lightBlue.shade300,
                width: 3,
                style: selected ? BorderStyle.solid : BorderStyle.none)),
        child: Material(
            borderRadius: BorderRadius.circular(4),
            color: Colors.transparent,
            child: InkWell(
                enableFeedback: false,
                onTap: () => buttonTap(value),
                onLongPress: () => buttonLongPress(value),
                child: Container(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(4),
                    child: DefaultTextStyle(
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade300),
                        child: buildButtonLabel(context, value))))));
  }

  Color buttonBgColor(A value) {
    return Colors.blueGrey.shade700;
  }

  bool isSelected(A value) {
    return filter.value.contains(valueToFilter(value));
  }

  void buttonTap(A value) {
    if (!multiselectEnabled) filter.value.clear();
    var filterValue = valueToFilter(value);
    if (!filter.value.contains(filterValue)) {
      filter.value.add(filterValue);
    } else if (filter.value.length > 1) {
      filter.value.remove(filterValue);
      if (filter.value.length == 1) {
        multiselectEnabled = false;
      }
    }
    controller.prioritize(this.filter);
    controller.update();
  }

  dynamic valueToFilter(A value) {
    return value;
  }

  A valueFromFilter(dynamic value) {
    return value;
  }

  void buttonLongPress(A value) {
    multiselectEnabled = true;
    buttonTap(value);
  }

  Widget buildButtonLabel(BuildContext context, A value) {
    return Text(value.toString());
  }
}
