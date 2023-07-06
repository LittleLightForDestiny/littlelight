import 'package:little_light/models/parsed_wishlist.dart';
import 'base_filter_values_options.dart';

class WishlistTagFilterOptions extends BaseFilterOptions<Set<WishlistTag?>> {
  WishlistTagFilterOptions(Set<WishlistTag> values)
      : super(
          values.toSet(),
          availableValues: values,
        );

  @override
  bool get available => availableValues.length > 1;
}
