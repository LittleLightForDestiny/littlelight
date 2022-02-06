//@dart=2.12
import 'package:flutter/material.dart';
import 'lore_root.page.dart';

class LorePageRouteArguments {
  final List<int>? parentCategoryHashes;
  final int? categoryPresentationNodeHash;

  LorePageRouteArguments(
      {this.parentCategoryHashes, this.categoryPresentationNodeHash});

  static LorePageRouteArguments? of(BuildContext context) {
    final pageRoute = ModalRoute.of(context);
    if (pageRoute?.settings.arguments is LorePageRouteArguments) {
      return pageRoute?.settings.arguments as LorePageRouteArguments;
    }
    return null;
  }
}

class LorePageRoute extends MaterialPageRoute {
  LorePageRoute({
    List<int>? parentCategoryHashes,
    int? categoryPresentationNodeHash,
  }) : super(
            settings: RouteSettings(
                arguments: LorePageRouteArguments(
              parentCategoryHashes: parentCategoryHashes,
              categoryPresentationNodeHash: categoryPresentationNodeHash,
            )),
            builder: (context) {
              return LoreRootPage();
            });
}
