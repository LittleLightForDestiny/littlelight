import 'base_filter_values_options.dart';

class PowerLevelConstraints {
  bool includePowerlessItems;
  int max;
  int min;
  PowerLevelConstraints({
    this.min = 0,
    this.max = 10,
    this.includePowerlessItems = true,
  });
}

class PowerLevelFilterOptions extends BaseFilterOptions<PowerLevelConstraints> {
  PowerLevelFilterOptions(
      PowerLevelConstraints value, PowerLevelConstraints availableValues)
      : super(value, availableValues: availableValues);
}
