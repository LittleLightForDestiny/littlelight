import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';

class DetailsItemCollectibleInfoWidget extends StatelessWidget {
  final int itemHash;

  const DetailsItemCollectibleInfoWidget(
    this.itemHash, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(itemHash);
    final collectibleDef = context.definition<DestinyCollectibleDefinition>(def?.collectibleHash);
    if (collectibleDef == null || collectibleDef.sourceString == null) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("How to get".translate(context).toUpperCase()),
          persistenceID: 'item collectible info',
          content: buildContent(context, collectibleDef),
        ));
  }

  Widget buildContent(BuildContext context, DestinyCollectibleDefinition loreDef) {
    final text = loreDef.sourceString;
    if (text == null) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SelectableText(
            text,
            style: context.textTheme.body,
            textAlign: TextAlign.left,
          ),
        ]));
  }
}
