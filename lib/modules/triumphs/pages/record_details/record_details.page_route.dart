import 'package:flutter/material.dart';

import 'record_details.page.dart';

class RecordDetailsPageRoute extends MaterialPageRoute {
  final int recordHash;

  RecordDetailsPageRoute(this.recordHash)
      : super(builder: (context) {
          return RecordDetailsPage(recordHash);
        });
}
