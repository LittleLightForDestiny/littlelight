import 'package:flutter/material.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/utils/item_filters/item_tag_filter.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class ItemTagFilterWidget extends BaseSearchFilterWidget<ItemTagFilter> {
  ItemTagFilterWidget(SearchController controller) : super(controller);

  @override
  _WishlistTagsFilterWidgetState createState() =>
      _WishlistTagsFilterWidgetState();
}

class _WishlistTagsFilterWidgetState extends BaseSearchFilterWidgetState<
    ItemTagFilterWidget, ItemTagFilter, ItemNotesTag> {
  @override
  Iterable<ItemNotesTag> get options {
    var tags = ItemNotesService().tagsByIds(filter.availableValues);
    return tags;
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Item Tags",
      uppercase: true,
    );
  }

  @override
  Widget buildButtons(BuildContext context) {
    return Column(
        children: options.map((o) => buildButton(context, o)).toList());
  }

  @override
  Widget buildButton(BuildContext context, ItemNotesTag value) {
    if (value == null) {
      return super.buildButton(context, value);
    }
    var length = options.length;
    if (options.contains(null)) length = length - 1;

    return Container(height: 40, child: super.buildButton(context, value));
  }

  @override
  Color buttonBgColor(ItemNotesTag value) {
    return value.backgroundColor;
  }

  @override
  Widget buildButtonLabel(BuildContext context, ItemNotesTag value) {
    var style = TextStyle(color: value.foregroundColor);
    var tagName = (value?.name?.length ?? 0) > 0 ? value?.name : null;
    return Row(children: [
      Icon(value.iconData, color: value.foregroundColor),
      Container(width: 4),
      ((value?.custom ?? false) && tagName != null)
          ? Text(tagName?.toUpperCase(), style: style)
          : TranslatedTextWidget(tagName ?? "Untitled",
              uppercase: true, style: style)
    ]);
  }

  @override
  Widget buildDisabledValue(BuildContext context) {
    return TranslatedTextWidget(
      "None",
      uppercase: true,
    );
  }

  @override
  valueToFilter(ItemNotesTag value) {
    return value.tagId;
  }
}
