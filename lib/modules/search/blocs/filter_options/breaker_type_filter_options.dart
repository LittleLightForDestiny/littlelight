import 'package:bungie_api/src/enums/destiny_breaker_type.dart';
import 'base_filter_values_options.dart';

class BreakerTypeFilterOptions extends BaseFilterOptions<Set<DestinyBreakerType>> {
  BreakerTypeFilterOptions(Set<DestinyBreakerType> value) : super(value.toSet(), availableValues: value);

  @override
  bool get available => availableValues.length > 1;
}
