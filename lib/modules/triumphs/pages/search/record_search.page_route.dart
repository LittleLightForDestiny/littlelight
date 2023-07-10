import 'package:flutter/material.dart';
import 'package:little_light/modules/triumphs/pages/search/record_search.page.dart';

class RecordsSearchPageRoute extends MaterialPageRoute {
  RecordsSearchPageRoute(int rootNode)
      : super(
            builder: (context) => RecordsSearchPage(
                  rootNode,
                ));
}
