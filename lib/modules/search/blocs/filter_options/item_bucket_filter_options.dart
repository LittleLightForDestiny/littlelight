import 'base_filter_values_options.dart';

class ItemBucketFilterOptions extends BaseFilterOptions<Set<int>> {
  ItemBucketFilterOptions(Set<int> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => availableValues.length > 1;
}
