import 'base_filter_values_options.dart';

class WeaponFrameFilterOptions extends BaseFilterOptions<Set<String>> {
  WeaponFrameFilterOptions(Set<String> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => availableValues.length > 1;

  Map<int, int> weaponTypeMap = {};
}
