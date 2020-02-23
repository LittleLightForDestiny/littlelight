import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/item_filters/item_bucket_filter.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/search/search.controller.dart';
import 'package:little_light/widgets/search/search_filters/base_search_filter.widget.dart';

class ItemBucketFilterWidget
    extends BaseSearchFilterWidget<ItemBucketFilter> {
  ItemBucketFilterWidget(SearchController controller) : super(controller);

  @override
  _ItemBucketFilterWidgetState createState() =>
      _ItemBucketFilterWidgetState();
}

class _ItemBucketFilterWidgetState extends BaseSearchFilterWidgetState<
    ItemBucketFilterWidget, ItemBucketFilter, int> {



  @override
  Widget buildButtonLabel(BuildContext context, int value) {
    return ManifestText<DestinyInventoryBucketDefinition>(value, key:Key("inventory_bucket_filter_$value"), uppercase: true,);
  }

  @override
  Widget buildFilterLabel(BuildContext context) {
    return TranslatedTextWidget("Slot", uppercase: true,);
  }
}
