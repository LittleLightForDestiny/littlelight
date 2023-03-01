import 'package:bungie_api/destiny2.dart';

import 'base_filter_values_options.dart';

class EnergyTypeFilterOptions
    extends BaseFilterOptions<Set<DestinyEnergyType?>> {
  EnergyTypeFilterOptions(Set<DestinyEnergyType> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => this.availableValues.length > 1;
}
