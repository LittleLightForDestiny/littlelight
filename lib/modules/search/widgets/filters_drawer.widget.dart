import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/armor_stats_filter.widget.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/power_level_filter.widget.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/tier_type_filter.widget.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/wishlist_tag_filter.widget.dart';

import 'drawer_filters/ammo_type_filter.widget.dart';
import 'drawer_filters/class_type_filter.widget.dart';
import 'drawer_filters/damage_type_filter.widget.dart';
import 'drawer_filters/energy_level_filter.widget.dart';
import 'drawer_filters/item_bucket_filter.widget.dart';
import 'drawer_filters/item_owner_filter.widget.dart';
import 'drawer_filters/item_subtype_filter.widget.dart';
import 'drawer_filters/item_tag_filter.widget.dart';
import 'drawer_filters/loadout_filter.widget.dart';

class FiltersDrawerWidget extends StatelessWidget {
  const FiltersDrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: context.theme.surfaceLayers.layer1,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// generic filters (all item types)
            PowerLevelFilterWidget(),
            ItemBucketFilterWidget(),
            ItemSubtypeFilterWidget(),
            TierTypeFilterWidget(),
            ItemOwnerFilterWidget(),

            /// weapon filter types
            AmmoTypeFilterWidget(),
            DamageTypeFilterWidget(),

            /// armor filter types
            EnergyLevelFilterWidget(),
            ClassTypeFilterWidget(),
            ArmorStatsFilterWidget(),

            /// LL specific stuff
            ItemTagFilterWidget(),
            LoadoutFilterWidget(),
            WishlistTagsFilterWidget()
          ],
        ),
      ),
    );
  }
}
