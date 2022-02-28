//@dart=2.12
import 'package:flutter/material.dart';
import 'package:little_light/pages/triumphs/triumphs_category.page.dart';
import 'package:little_light/pages/triumphs/triumphs_search.page.dart';

import 'triumphs_root.page.dart';

class TriumphsPageRouteArguments {
  final List<int>? parentCategoryHashes;
  final int? categoryPresentationNodeHash;
  final int? subcategoryPresentationNodeHash;
  final int? badgeCategoryHash;

  TriumphsPageRouteArguments(
      {this.parentCategoryHashes,
      this.categoryPresentationNodeHash,
      this.subcategoryPresentationNodeHash,
      this.badgeCategoryHash});

  static TriumphsPageRouteArguments? of(BuildContext context) {
    final pageRoute = ModalRoute.of(context);
    if (pageRoute?.settings.arguments is TriumphsPageRouteArguments) {
      return pageRoute?.settings.arguments as TriumphsPageRouteArguments;
    }
    return null;
  }
}

class TriumphsPageRoute extends MaterialPageRoute {
  TriumphsPageRoute({
    List<int>? parentCategoryHashes,
    int? categoryPresentationNodeHash,
    int? subcategoryPresentationNodeHash,
    int? badgeCategoryHash,
  }) : super(
            settings: RouteSettings(
                arguments: TriumphsPageRouteArguments(
                    parentCategoryHashes: parentCategoryHashes,
                    categoryPresentationNodeHash: categoryPresentationNodeHash,
                    subcategoryPresentationNodeHash: subcategoryPresentationNodeHash,
                    badgeCategoryHash: badgeCategoryHash)),
            builder: (context) {
              if (categoryPresentationNodeHash != null) {
                return TriumphsCategoryPage();
              }
              return TriumphsRootPage();
            });
}

class TriumphsSearchPageRoute extends MaterialPageRoute {
  TriumphsSearchPageRoute()
      : super(builder: (context) {
          return TriumphsSearchPage();
        });
}
