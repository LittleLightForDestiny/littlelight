import 'package:bungie_api/destiny2.dart';

import 'base_filter_values_options.dart';

class TierTypeFilterOptions extends BaseFilterOptions<Set<TierType>> {
  TierTypeFilterOptions(Set<TierType> availableValues)
      : super(
          availableValues,
          availableValues: availableValues,
        );
}
