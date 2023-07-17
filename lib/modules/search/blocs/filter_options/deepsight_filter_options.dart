import 'base_filter_values_options.dart';

class DeepsightFilterOptions extends BaseFilterOptions<Set<bool>> {
  DeepsightFilterOptions(Set<bool> value) : super(value.toSet(), availableValues: value);

  @override
  bool get available => availableValues.length > 1;
}
