import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemCollectibleInfoWidget extends StatelessWidget {
  final int hash;

  ItemCollectibleInfoWidget(
      this.hash,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(hash == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "How to get",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(
              padding: EdgeInsets.all(8),
              child: ManifestText<DestinyCollectibleDefinition>(
                  hash,
                  textExtractor: (collectible){
                    if(collectible == null) return "";
                    return collectible.sourceString;
                  },))
        ],
      ),
    );
  }
}
