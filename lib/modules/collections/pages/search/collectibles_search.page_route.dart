import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/pages/search/collectibles_search.page.dart';

class CollectiblesSearchPageRoute extends MaterialPageRoute {
  CollectiblesSearchPageRoute(int rootNode)
      : super(
            builder: (context) => CollectiblesSearchPage(
                  rootNode,
                ));
}
