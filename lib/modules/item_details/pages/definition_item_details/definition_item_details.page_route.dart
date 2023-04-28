import 'package:flutter/material.dart';

import 'definition_item_details.page.dart';

class DefinitionItemDetailsPageRoute extends MaterialPageRoute {
  final int itemHash;

  DefinitionItemDetailsPageRoute(this.itemHash)
      : super(builder: (context) {
          return DefinitionItemDetailsPage(itemHash);
        });
}
