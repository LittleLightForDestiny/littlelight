import 'base_filter_values_options.dart';

class ArmorStatsConstraints {
  int max;
  int min;
  ArmorStatsConstraints({this.min = 9999, this.max = -9999});
}

class ArmorStatsFilterOptions extends BaseFilterOptions<ArmorStatsConstraints> {
  ArmorStatsFilterOptions([ArmorStatsConstraints? value])
      : super(value ?? ArmorStatsConstraints(min: -9999, max: 9999), availableValues: ArmorStatsConstraints());

  @override
  bool get available => availableValues.max > availableValues.min;
}
