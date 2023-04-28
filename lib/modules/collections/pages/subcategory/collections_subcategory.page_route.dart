import 'package:flutter/material.dart';

import 'collections_subcategory.page.dart';

class CollectionsSubcategoryPageRoute extends MaterialPageRoute {
  CollectionsSubcategoryPageRoute(
    int categoryPresentationNodeHash,
  ) : super(builder: (context) => CollectionsSubcategoryPage(categoryPresentationNodeHash));
}
