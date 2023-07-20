import 'base_filter_values_options.dart';

class CraftedFilterOptions extends BaseFilterOptions<Set<bool>> {
  CraftedFilterOptions(Set<bool> value) : super(value.toSet(), availableValues: value);

  @override
  bool get available => availableValues.length > 1;
}
