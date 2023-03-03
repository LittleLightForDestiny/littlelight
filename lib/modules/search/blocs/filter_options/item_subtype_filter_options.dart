import 'base_filter_values_options.dart';

class ItemSubtypeFilterOptions extends BaseFilterOptions<Set<int>> {
  ItemSubtypeFilterOptions(Set<int> availableValues)
      : super(
          availableValues.toSet(),
          availableValues: availableValues,
        );

  @override
  bool get available => availableValues.length > 1;
}
