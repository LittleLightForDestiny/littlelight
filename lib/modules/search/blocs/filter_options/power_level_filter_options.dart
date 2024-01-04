import 'base_filter_values_options.dart';

class PowerLevelConstraints {
  bool includePowerlessItems;
  int max;
  int min;
  PowerLevelConstraints({
    this.min = 9999,
    this.max = -9999,
    this.includePowerlessItems = true,
  });
}

class PowerLevelFilterOptions extends BaseFilterOptions<PowerLevelConstraints> {
  PowerLevelFilterOptions([PowerLevelConstraints? value])
      : super(value ?? PowerLevelConstraints(min: -9999, max: 9999), availableValues: PowerLevelConstraints());

  @override
  bool get available => availableValues.max > availableValues.min;
}
