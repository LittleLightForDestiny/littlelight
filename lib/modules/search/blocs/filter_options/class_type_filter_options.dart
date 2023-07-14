import 'package:bungie_api/destiny2.dart';
import 'base_filter_values_options.dart';

class ClassTypeFilterOptions extends BaseFilterOptions<Set<DestinyClass>> {
  ClassTypeFilterOptions() : super(<DestinyClass>{}, availableValues: <DestinyClass>{});

  @override
  bool get available => availableValues.length > 1;
}
