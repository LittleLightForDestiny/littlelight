import 'base_filter_values_options.dart';

class EnergyLevelConstraints {
  bool includeEnergylessItems;
  int max;
  int min;
  EnergyLevelConstraints({
    this.min = 99,
    this.max = -99,
    this.includeEnergylessItems = false,
  });
}

class EnergyLevelFilterOptions extends BaseFilterOptions<EnergyLevelConstraints> {
  EnergyLevelFilterOptions([EnergyLevelConstraints? value])
      : super(value ?? EnergyLevelConstraints(min: -99, max: 99), availableValues: EnergyLevelConstraints());

  @override
  bool get available => availableValues.max > availableValues.min;
}
