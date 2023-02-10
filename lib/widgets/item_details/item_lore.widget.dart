// @dart=2.9

import 'package:bungie_api/models/destiny_lore_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';

class ItemLoreWidget extends StatefulWidget {
  final int hash;

  const ItemLoreWidget(this.hash, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemLoreWidgetState();
  }
}

const _sectionId = "item_lore";

class ItemLoreWidgetState extends State<ItemLoreWidget> with VisibleSectionMixin {
  @override
  String get sectionId => _sectionId;

  @override
  Widget build(BuildContext context) {
    if (widget.hash == null) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getHeader(
            TranslatedTextWidget(
              "Lore",
              uppercase: true,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          visible
              ? Container(
                  padding: const EdgeInsets.all(8),
                  child: DefinitionProviderWidget<DestinyLoreDefinition>(
                      widget.hash,
                      (def) => SelectableText(
                            def?.displayProperties?.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                            ),
                          )))
              : Container()
        ],
      ),
    );
  }
}
