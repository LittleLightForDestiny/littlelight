import 'package:bungie_api/destiny2.dart';
import 'base_filter_values_options.dart';

class TierTypeFilterOptions extends BaseFilterOptions<Set<TierType>> {
  final Map<TierType, String> names = {};
  TierTypeFilterOptions(Set<TierType> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => availableValues.length > 1;
}
