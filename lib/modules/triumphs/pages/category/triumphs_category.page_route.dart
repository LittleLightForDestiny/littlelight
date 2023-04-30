import 'package:flutter/material.dart';
import 'triumphs_category.page.dart';

class TriumphsCategoryPageRoute extends MaterialPageRoute {
  TriumphsCategoryPageRoute(
    int categoryPresentationNodeHash, {
    List<int>? parentNodeHashes,
  }) : super(
            builder: (context) => TriumphsCategoryPage(
                  categoryPresentationNodeHash,
                  parentNodeHashes: parentNodeHashes,
                ));
}
