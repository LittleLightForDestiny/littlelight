import 'package:little_light/models/parsed_wishlist.dart';

import 'base_filter_values_options.dart';

class WishlistTagFilterOptions extends BaseFilterOptions<Set<WishlistTag>> {
  WishlistTagFilterOptions(Set<WishlistTag> availableValues)
      : super(
          availableValues,
          availableValues: availableValues,
        );
}
