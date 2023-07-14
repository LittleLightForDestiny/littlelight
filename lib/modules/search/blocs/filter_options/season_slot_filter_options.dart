import 'base_filter_values_options.dart';

class SeasonSlotFilterOptions extends BaseFilterOptions<Set<int>> {
  SeasonSlotFilterOptions(Set<int> value, Set<int> availableValues)
      : super(value, availableValues: availableValues);
}
