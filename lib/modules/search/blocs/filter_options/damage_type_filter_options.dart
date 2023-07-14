import 'package:bungie_api/destiny2.dart';
import 'base_filter_values_options.dart';

class DamageTypeFilterOptions extends BaseFilterOptions<Set<DamageType>> {
  DamageTypeFilterOptions(Set<DamageType> values) : super(values.toSet(), availableValues: values);

  @override
  bool get available => super.available;
}
