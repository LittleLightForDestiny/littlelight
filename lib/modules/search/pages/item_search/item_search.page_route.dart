import 'package:flutter/material.dart';
import 'package:little_light/modules/search/pages/item_search/item_search.page.dart';

class ItemSearchPageRoute extends MaterialPageRoute {
  ItemSearchPageRoute({
    required int bucketHash,
    required String? characterId,
  }) : super(builder: (context) {
          return ItemSearchPage();
        });
}
