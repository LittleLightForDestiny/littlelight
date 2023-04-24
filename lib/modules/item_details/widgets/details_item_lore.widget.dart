import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';

class DetailsItemLoreWidget extends StatelessWidget {
  final int itemHash;

  const DetailsItemLoreWidget(
    this.itemHash, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final def = context.definition<DestinyInventoryItemDefinition>(itemHash);
    final loreDef = context.definition<DestinyLoreDefinition>(def?.loreHash);
    if (loreDef == null || loreDef.displayProperties?.description == null) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Lore".translate(context).toUpperCase()),
          persistenceID: 'item lore',
          content: buildContent(context, loreDef),
        ));
  }

  Widget buildContent(BuildContext context, DestinyLoreDefinition loreDef) {
    final text = loreDef.displayProperties?.description;
    final subtitle = loreDef.subtitle;
    if (text == null) return Container();
    return Container(
        padding: EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (subtitle != null)
            Container(
              child: SelectableText(
                subtitle,
                style: context.textTheme.subtitle,
                textAlign: TextAlign.left,
              ),
              padding: EdgeInsets.only(bottom: 8),
            ),
          SelectableText(
            text,
            style: context.textTheme.body,
            textAlign: TextAlign.left,
          ),
        ]));
  }
}
