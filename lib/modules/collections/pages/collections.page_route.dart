import 'package:flutter/material.dart';
import 'badge/collections_badge.page.dart';
import 'category/collections_category.page.dart';
import 'search/collections_search.page.dart';
import 'subcategory/collections_subcategory.page.dart';

import 'home/collections_root.page.dart';

class CollectionsPageRouteArguments {
  final List<int>? parentCategoryHashes;
  final int? categoryPresentationNodeHash;
  final int? subcategoryPresentationNodeHash;
  final int? badgeCategoryHash;

  CollectionsPageRouteArguments(
      {this.parentCategoryHashes,
      this.categoryPresentationNodeHash,
      this.subcategoryPresentationNodeHash,
      this.badgeCategoryHash});

  static CollectionsPageRouteArguments? of(BuildContext context) {
    final pageRoute = ModalRoute.of(context);
    if (pageRoute?.settings.arguments is CollectionsPageRouteArguments) {
      return pageRoute?.settings.arguments as CollectionsPageRouteArguments;
    }
    return null;
  }
}

class CollectionsPageRoute extends MaterialPageRoute {
  CollectionsPageRoute({
    List<int>? parentCategoryHashes,
    int? categoryPresentationNodeHash,
    int? subcategoryPresentationNodeHash,
    int? badgeCategoryHash,
  }) : super(
            settings: RouteSettings(
                arguments: CollectionsPageRouteArguments(
                    parentCategoryHashes: parentCategoryHashes,
                    categoryPresentationNodeHash: categoryPresentationNodeHash,
                    subcategoryPresentationNodeHash:
                        subcategoryPresentationNodeHash,
                    badgeCategoryHash: badgeCategoryHash)),
            builder: (context) {
              if (subcategoryPresentationNodeHash != null) {
                return CollectionsSubcategoryPage();
              }
              if (categoryPresentationNodeHash != null) {
                return CollectionsCategoryPage();
              }
              if (badgeCategoryHash != null) {
                return CollectionsBadgePage();
              }
              return CollectionsRootPage();
            });
}

class CollectionsSearchPageRoute extends MaterialPageRoute {
  CollectionsSearchPageRoute()
      : super(builder: (context) {
          return const CollectionsSearchPage();
        });
}
