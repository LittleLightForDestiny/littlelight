import 'base_filter_values_options.dart';

class ItemTagFilterOptions extends BaseFilterOptions<Set<String>> {
  ItemTagFilterOptions(Set<String> availableValues)
      : super(
          availableValues,
          availableValues: availableValues,
        );
}
