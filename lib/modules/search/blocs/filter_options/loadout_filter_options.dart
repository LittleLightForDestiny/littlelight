import 'base_filter_values_options.dart';

class LoadoutFilterOptions extends BaseFilterOptions<Set<String>> {
  LoadoutFilterOptions(Set<String> availableValues)
      : super(
          availableValues,
          availableValues: availableValues,
        );
}
