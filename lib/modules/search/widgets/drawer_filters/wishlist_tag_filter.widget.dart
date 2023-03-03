import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/parsed_wishlist.dart';
import 'package:little_light/modules/search/blocs/filter_options/wishlist_tag_filter_options.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/shared/utils/extensions/wishlist_tag_data.dart';
import 'package:little_light/utils/destiny_data.dart';

import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class WishlistTagsFilterWidget extends BaseDrawerFilterWidget<WishlistTagFilterOptions> with WishlistsConsumer {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Wishlist Tags".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, WishlistTagFilterOptions data) {
    final availableValues = data.availableValues;
    final values = data.value;
    final allTags = [WishlistTag.GodPVE, WishlistTag.GodPVP, WishlistTag.PVE, WishlistTag.PVP];
    final availableTags = allTags.where((t) => availableValues.contains(t));
    final showNone = availableValues.contains(null);
    return Column(
      children: availableTags
              .map(
                (tag) => FilterButtonWidget(
                  Row(children: [
                    Icon(
                      tag.getIcon(context),
                      color: tag.getForegroundColor(context),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tag.name,
                        style: TextStyle(color: tag.getForegroundColor(context)),
                      ),
                    ),
                  ]),
                  background: Container(color: tag.getColor(context)),
                  selected: values.contains(tag),
                  onTap: () => updateOption(context, data, tag, false),
                  onLongPress: () => updateOption(context, data, tag, true),
                ),
              )
              .toList() +
          [
            if (showNone)
              FilterButtonWidget(
                Row(children: [
                  Icon(
                    FontAwesomeIcons.ban,
                    color: context.theme.onSurfaceLayers.layer1,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    "None".translate(context).toUpperCase(),
                    style: TextStyle(inherit: true, color: context.theme.onSurfaceLayers.layer1),
                  )),
                ]),
                selected: values.contains(null),
                onTap: () => updateOption(context, data, null, false),
                onLongPress: () => updateOption(context, data, null, true),
              ),
          ],
    );
  }

  Widget buildIcon(BuildContext context, DamageType type) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Icon(
          type.icon,
          color: type.getColorLayer(context).layer3,
        ));
  }
}
