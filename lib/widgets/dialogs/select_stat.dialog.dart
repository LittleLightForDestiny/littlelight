import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

class SelectStatDialogRoute extends DialogRoute<int?> {
  SelectStatDialogRoute(BuildContext context, List<int> statHashes)
      : super(
            context: context, builder: (context) => SelectStatDialog(), settings: RouteSettings(arguments: statHashes));
}

class SelectStatDialog extends LittleLightBaseDialog {
  SelectStatDialog() : super(titleBuilder: (context) => TranslatedTextWidget('Select Stat'));

  @override
  Widget? buildBody(BuildContext context) {
    final hashes = ModalRoute.of(context)?.settings.arguments;
    if (hashes is List<int>) {
      return ListView.builder(
          itemCount: hashes.length,
          itemExtent: 48,
          itemBuilder: (context, index) => buildStatItem(context, hashes[index]));
    }
    return Container();
  }

  Widget buildStatItem(BuildContext context, int hash) => Container(
      padding: EdgeInsets.all(4).copyWith(top: 0),
      child: Material(
          color: Colors.blueGrey,
          child: InkWell(
              onTap: () {
                Navigator.of(context).pop(hash);
              },
              child: Container(
                  padding: EdgeInsets.all(8),
                  alignment: Alignment.centerLeft,
                  child: ManifestText<DestinyStatDefinition>(hash)))));

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: TranslatedTextWidget("Cancel", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop(null);
          },
        ),
      ],
    );
  }
}
