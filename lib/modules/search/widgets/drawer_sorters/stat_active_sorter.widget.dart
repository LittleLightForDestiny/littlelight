import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

import 'active_sorter.widget.dart';

class StatActiveSorterWidget extends ActiveSorterWidget {
  StatActiveSorterWidget(ItemSortParameter parameter, int index) : super(parameter, index);

  Widget buildName(BuildContext context) {
    return ManifestText<DestinyStatDefinition>(
      parameter.customData?['statHash'],
      uppercase: true,
    );
  }
}
