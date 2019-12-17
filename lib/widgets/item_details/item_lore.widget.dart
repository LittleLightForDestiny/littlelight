import 'package:bungie_api/models/destiny_lore_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ItemLoreWidget extends StatelessWidget {
  final int hash;

  ItemLoreWidget(this.hash, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hash == null) {
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
              "Lore",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(
              padding: EdgeInsets.all(8),
              child: DefinitionProviderWidget<DestinyLoreDefinition>(
                  hash,
                  (def) => SelectableText(
                        def?.displayProperties?.description,
                        style: TextStyle(fontWeight: FontWeight.w300),
                      )))
        ],
      ),
    );
  }
}
