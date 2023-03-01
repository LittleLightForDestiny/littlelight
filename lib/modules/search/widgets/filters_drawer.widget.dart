import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/search/widgets/energy_type_filter.widget.dart';
import 'package:little_light/modules/search/widgets/item_bucket_filter.widget.dart';
import 'package:little_light/modules/search/widgets/item_owner_filter.widget.dart';

import 'ammo_type_filter.widget.dart';
import 'class_type_filter.widget.dart';
import 'damage_type_filter.widget.dart';
import 'energy_level_filter.widget.dart';

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
            AmmoTypeFilterWidget(),
            DamageTypeFilterWidget(),
            ClassTypeFilterWidget(),
            EnergyLevelFilterWidget(),
            EnergyTypeFilterWidget(),
            ItemBucketFilterWidget(),
            ItemOwnerFilterWidget(),
          ],
        ),
      ),
    );
  }
}
