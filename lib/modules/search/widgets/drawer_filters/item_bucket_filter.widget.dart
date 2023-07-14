import 'package:bungie_api/destiny2.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_bucket_filter_options.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'base_drawer_filter.widget.dart';
import 'filter_button.widget.dart';

class ItemBucketFilterWidget extends BaseDrawerFilterWidget<ItemBucketFilterOptions> with ManifestConsumer {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Slot".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, ItemBucketFilterOptions data) {
    final availableValues = data.availableValues;
    final values = data.value;
    return FutureBuilder<Map<int, DestinyInventoryBucketDefinition>>(
      builder: (context, snapshot) {
        final defs = snapshot.data;
        if (defs == null) return Container();
        final orderedValues = availableValues.sorted((a, b) {
          final defA = defs[a];
          final defB = defs[b];
          final indexA = defA?.index ?? double.maxFinite.toInt();
          final indexB = defB?.index ?? double.maxFinite.toInt();
          return indexA.compareTo(indexB);
        });
        return Column(
          children: orderedValues
              .map(
                (type) => SizedBox(
                  child: FilterButtonWidget(
                    ManifestText<DestinyInventoryBucketDefinition>(type, uppercase: true),
                    selected: values.contains(type),
                    onTap: () => updateOption(context, data, type, false),
                    onLongPress: () => updateOption(context, data, type, true),
                  ),
                ),
              )
              .toList(),
        );
      },
      future: manifest.getDefinitions<DestinyInventoryBucketDefinition>(availableValues),
    );
  }
}
