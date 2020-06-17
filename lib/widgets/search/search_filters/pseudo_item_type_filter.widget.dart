import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/pseudo_item_type_filter.dart';
import 'package:little_light/widgets/common/refresh_button.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class PseudoItemTypeFilterWidget
    extends BaseSearchFilterWidget<PseudoItemTypeFilter> {
  PseudoItemTypeFilterWidget(SearchController controller) : super(controller);

  @override
  _PseudoItemTypeFilterWidgetState createState() =>
      _PseudoItemTypeFilterWidgetState();
}

class _PseudoItemTypeFilterWidgetState extends BaseSearchFilterWidgetState<
    PseudoItemTypeFilterWidget, PseudoItemTypeFilter, PseudoItemType> {

  @override
  Widget build(BuildContext context) {
    double paddingBottom = MediaQuery.of(context).padding.bottom;
    return Container(
        height: 40 + paddingBottom,
        padding: EdgeInsets.only(bottom: paddingBottom),
        color: Colors.black,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: Container(height: 40, child: buildButtons(context))),
          Container(height: 40, width: 40, child: RefreshButtonWidget())
        ]));
  }

  @override
  Widget buildButtons(BuildContext context) {
    if((filter?.availableValues?.length ?? 0) <= 1) return Container();
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filter.availableValues
              .map((e) => buildButton(context, e))
              .toList(),
        ));
  }

  @override
  Widget buildButton(BuildContext context, PseudoItemType value) {
    bool isSelected = filter.value.contains(value);
    var query = MediaQuery.of(context);
    return Container(
      constraints: BoxConstraints(
          minWidth: (query.size.width - 40) / filter.availableValues.length),
      child: Material(
          color: isSelected ? Colors.blueGrey.shade700 : Colors.transparent,
          child: InkWell(
            child: Container(
                foregroundDecoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 2))),
                alignment: Alignment.center,
                padding: EdgeInsets.all(8),
                child: buildButtonLabel(context, value)),
            onTap: () {
              if (isSelected && filter.value.length <= 1) return;
              if (!isSelected) {
                if(filter.value.length <= 1) filter.value.clear();
                filter.value.add(value);
              }else{
                filter.value.remove(value);
              }
              widget.controller.update();
            },
            onLongPress: (){
              filter.value.add(value);
              widget.controller.update();
            },
          )),
    );
  }

  @override
  Widget buildButtonLabel(BuildContext context, PseudoItemType value) {
    var style = TextStyle(color: Colors.white, fontWeight: FontWeight.w500);
    switch (value) {
      case PseudoItemType.Weapons:
        return TranslatedTextWidget(
          "Weapons",
          style: style,
          uppercase: true,
        );
        break;
      case PseudoItemType.Armor:
        return TranslatedTextWidget(
          "Armor",
          style: style,
          uppercase: true,
        );
        break;
      case PseudoItemType.Cosmetics:
        return TranslatedTextWidget(
          "Cosmetics",
          style: style,
          uppercase: true,
        );
        break;
      case PseudoItemType.Pursuits:
        return TranslatedTextWidget(
          "Pursuits",
          style: style,
          uppercase: true,
        );
        break;
      case PseudoItemType.Consumables:
        return TranslatedTextWidget(
          "Inventory",
          style: style,
          uppercase: true,
        );
        break;
    }
    return Text(
      value.toString().split('.').last,
      style: style,
    );
  }
}
