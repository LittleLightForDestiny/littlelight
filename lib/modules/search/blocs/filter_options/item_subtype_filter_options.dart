import 'package:bungie_api/destiny2.dart';

import 'base_filter_values_options.dart';

class ItemSubtypeFilterOptions
    extends BaseFilterOptions<Set<DestinyItemSubType>> {
  ItemSubtypeFilterOptions(Set<DestinyItemSubType> availableValues)
      : super(
          availableValues,
          availableValues: availableValues,
        );
}
