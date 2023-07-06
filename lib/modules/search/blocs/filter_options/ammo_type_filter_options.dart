import 'package:bungie_api/destiny2.dart';
import 'base_filter_values_options.dart';

class AmmoTypeFilterOptions extends BaseFilterOptions<Set<DestinyAmmunitionType>> {
  AmmoTypeFilterOptions(Set<DestinyAmmunitionType> value) : super(value.toSet(), availableValues: value);

  @override
  bool get available => availableValues.length > 1;
}
