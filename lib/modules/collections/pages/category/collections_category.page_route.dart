import 'package:flutter/material.dart';
import 'package:little_light/modules/collections/pages/category/collections_category.page.dart';

class CollectionsCategoryPageRoute extends MaterialPageRoute {
  CollectionsCategoryPageRoute(
    int categoryPresentationNodeHash,
  ) : super(builder: (context) => CollectionsCategoryPage(categoryPresentationNodeHash));
}
