import 'package:flutter/material.dart';
import 'collections_subcategory.page.dart';

class CollectionsSubcategoryPageRoute extends MaterialPageRoute {
  CollectionsSubcategoryPageRoute(
    int categoryPresentationNodeHash, {
    List<int>? parentNodeHashes,
  }) : super(
            builder: (context) => CollectionsSubcategoryPage(
                  categoryPresentationNodeHash,
                  parentNodeHashes: parentNodeHashes,
                ));
}
