import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';
import 'base_filter_values_options.dart';

class MainItemTypeFilterOptions extends BaseFilterOptions<Set<EquipmentBucketGroup>> {
  MainItemTypeFilterOptions(Set<EquipmentBucketGroup> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => true;

  @override
  set value(Set<EquipmentBucketGroup> value) {
    super.value = value;
    enabled = true;
  }
}
