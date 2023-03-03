import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_tag_filter_options.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/utils/destiny_data.dart';

import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class ItemTagFilterWidget extends BaseDrawerFilterWidget<ItemTagFilterOptions> with ItemNotesConsumer {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Item Tags".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, ItemTagFilterOptions data) {
    final availableValues = data.availableValues;
    final values = data.value;
    final allTags = itemNotes.getAvailableTags();
    final availableTags = allTags.where((t) => availableValues.contains(t.tagId));
    final showNone = availableValues.contains(null);
    return Column(
      children: availableTags
              .map(
                (tag) => FilterButtonWidget(
                  Row(children: [
                    Icon(
                      tag.iconData,
                      color: tag.foregroundColor,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text(
                      (tag.custom ? tag.name : tag.name.translate(context)).toUpperCase(),
                      style: TextStyle(inherit: true, color: tag.foregroundColor),
                    )),
                  ]),
                  background: Container(color: tag.backgroundColor),
                  selected: values.contains(tag.tagId),
                  onTap: () => updateOption(context, data, tag.tagId, false),
                  onLongPress: () => updateOption(context, data, tag.tagId, true),
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
