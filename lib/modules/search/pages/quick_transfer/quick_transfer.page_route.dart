import 'package:flutter/material.dart';
import 'package:little_light/modules/search/pages/quick_transfer/quick_transfer.page.dart';

class QuickTransferPageRouteArguments {
  final int bucketHash;
  final String? characterId;

  QuickTransferPageRouteArguments({
    required this.bucketHash,
    required this.characterId,
  });

  static QuickTransferPageRouteArguments? of(BuildContext context) {
    final pageRoute = ModalRoute.of(context);
    if (pageRoute?.settings.arguments is QuickTransferPageRouteArguments) {
      return pageRoute?.settings.arguments as QuickTransferPageRouteArguments;
    }
    return null;
  }
}

class QuickTransferPageRoute extends MaterialPageRoute {
  QuickTransferPageRoute({
    required int bucketHash,
    required String? characterId,
  }) : super(
            settings: RouteSettings(
                arguments: QuickTransferPageRouteArguments(
              bucketHash: bucketHash,
              characterId: characterId,
            )),
            builder: (context) {
              return QuickTransferPage();
            });
}
