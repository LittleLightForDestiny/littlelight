import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:little_light/shared/widgets/containers/menu_info_box.dart';
import 'package:little_light/shared/widgets/containers/persistent_collapsible_container.dart';
import 'package:little_light/shared/widgets/external_references/the_old_ghost_link.button.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

class DetailsRecordLoreWidget extends StatelessWidget {
  final int recordHash;

  const DetailsRecordLoreWidget(
    this.recordHash, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final def = context.definition<DestinyRecordDefinition>(recordHash);
    final loreDef = context.definition<DestinyLoreDefinition>(def?.loreHash);
    if (loreDef == null || loreDef.displayProperties?.description == null) return Container();
    return Container(
        padding: EdgeInsets.all(4),
        child: PersistentCollapsibleContainer(
          title: Text("Lore".translate(context).toUpperCase()),
          persistenceID: 'record lore',
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
          if (subtitle != null && subtitle.isNotEmpty)
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
          buildExternalReferences(context)
        ]));
  }

  Widget buildExternalReferences(BuildContext context) {
    final definition = context.definition<DestinyRecordDefinition>(recordHash);
    final loreHash = definition?.loreHash;
    if (loreHash == null) return Container();
    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.secondarySurfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              margin: EdgeInsets.only(bottom: 4),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.theme.secondarySurfaceLayers.layer0,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Read more at".translate(context),
                style: context.textTheme.button,
              )),
          Wrap(
            children: [
              TheOldGhostLinkButton(
                contentType: OldGhostContentType.Chapter,
                hash: loreHash,
                name: definition?.displayProperties?.name,
              )
            ],
          )
        ],
      ),
    );
  }
}
