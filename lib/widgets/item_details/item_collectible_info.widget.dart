// @dart=2.9

import 'package:bungie_api/models/destiny_collectible_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';

class ItemCollectibleInfoWidget extends StatefulWidget {
  final int hash;

  ItemCollectibleInfoWidget(this.hash, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemCollectibleInfoWidgetState();
  }
}

const _sectionId = "item_collectible_info";

class ItemCollectibleInfoWidgetState extends State<ItemCollectibleInfoWidget>
    with VisibleSectionMixin {
  @override
  String get sectionId => _sectionId;

  @override
  Widget build(BuildContext context) {
    if (widget.hash == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          getHeader(
            TranslatedTextWidget(
              "How to get",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          visible
              ? Container(
                  padding: EdgeInsets.all(8),
                  child: ManifestText<DestinyCollectibleDefinition>(
                    widget.hash,
                    style: TextStyle(fontWeight: FontWeight.w300),
                    textExtractor: (collectible) {
                      if (collectible == null) return "";
                      return collectible.sourceString;
                    },
                  ))
              : Container()
        ],
      ),
    );
  }
}
