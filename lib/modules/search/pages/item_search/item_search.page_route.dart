import 'package:bungie_api/src/enums/destiny_class.dart';
import 'package:flutter/material.dart';
import 'package:little_light/modules/search/pages/item_search/item_search.page.dart';
import 'package:little_light/shared/utils/helpers/bucket_type_groups.dart';

class ItemSearchPageRoute extends MaterialPageRoute {
  ItemSearchPageRoute(EquipmentBucketGroup? currentBucketGroup, DestinyClass? classType)
      : super(builder: (context) {
          return ItemSearchPage(currentBucketGroup, classType);
        });
}
