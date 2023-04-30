import 'package:flutter/material.dart';

import 'triumphs_subcategory.page.dart';

class TriumphsSubcategoryPageRoute extends MaterialPageRoute {
  TriumphsSubcategoryPageRoute(
    int categoryPresentationNodeHash, {
    List<int>? parentNodeHashes,
  }) : super(
            builder: (context) => TriumphsSubcategoryPage(
                  categoryPresentationNodeHash,
                  parentNodeHashes: parentNodeHashes,
                ));
}
