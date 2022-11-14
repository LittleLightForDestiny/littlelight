// @dart=2.9

import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/utils/item_filters/wishlist_tag_filter.dart';
import 'package:little_light/utils/wishlists_data.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/common/wishlist_badges.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';
import 'package:flutter/material.dart';

class WishlistTagsFilterWidget extends BaseSearchFilterWidget<WishlistTagFilter> {
  WishlistTagsFilterWidget(SearchController controller) : super(controller);

  @override
  _WishlistTagsFilterWidgetState createState() => _WishlistTagsFilterWidgetState();
}

class _WishlistTagsFilterWidgetState
    extends BaseSearchFilterWidgetState<WishlistTagsFilterWidget, WishlistTagFilter, WishlistTag> {
  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget(
      "Wishlist Tags",
      uppercase: true,
    );
  }

  @override
  Widget buildButtons(BuildContext context) {
    return Wrap(children: options.map((o) => buildButton(context, o)).toList());
  }

  @override
  Widget buildButton(BuildContext context, WishlistTag value) {
    if (value == null) {
      return super.buildButton(context, value);
    }
    var length = options.length;
    if (options.contains(null)) length = length - 1;
    if (length % 2 == 0) {
      return FractionallySizedBox(
          widthFactor: .5, child: Container(height: 70, child: super.buildButton(context, value)));
    } else {
      return FractionallySizedBox(
          widthFactor: 1 / 3, child: Container(height: 70, child: super.buildButton(context, value)));
    }
  }

  @override
  Color buttonBgColor(WishlistTag value) {
    return WishlistsData.getBgColor(context, value);
  }

  @override
  Widget buildButtonLabel(BuildContext context, WishlistTag value) {
    var children = <Widget>[
      WishlistsData.getIcon(context, value, 24),
      Container(width: 4, height: 4),
      WishlistsData.getLabel(value, context)
    ];
    return DefaultTextStyle(
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        child: value == null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ));
  }

  @override
  Widget buildDisabledValue(BuildContext context) {
    try {
      var tag = this.filter.value.single;
      return WishlistBadgesWidget(tags: [tag].toSet());
    } catch (_) {}
    return TranslatedTextWidget(
      "None",
      uppercase: true,
    );
  }
}
