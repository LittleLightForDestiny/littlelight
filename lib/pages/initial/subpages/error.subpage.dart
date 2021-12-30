//@dart=2.12

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/storage/storage.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class StartupErrorSubPage extends StatefulWidget {
  StartupErrorSubPage();

  @override
  StartupErrorSubPageState createState() => new StartupErrorSubPageState();
}

class StartupErrorSubPageState extends SubpageBaseState<StartupErrorSubPage> with StorageConsumer {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildTitle(BuildContext context) => TranslatedTextWidget(
        "There was an error",
      );

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(children: [
        ElevatedButton(
            onPressed: () async {
              await this.globalStorage.purge();
              Phoenix.rebirth(context);
            },
            child: TranslatedTextWidget("Clear data and restart")),
      ]));
}
