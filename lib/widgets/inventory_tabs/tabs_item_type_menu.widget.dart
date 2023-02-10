// @dart=2.9

import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

typedef OnSelect = void Function(dynamic categoryHash);

class ItemTypeMenuWidget extends StatelessWidget {
  final TabController controller;
  final List<int> groups;

  const ItemTypeMenuWidget(this.groups, {Key key, this.controller})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      color: Colors.black,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: TabBar(
            indicator: BoxDecoration(
                border: Border(top: BorderSide(width: 2, color: Theme.of(context).colorScheme.onSurface))),
            controller: controller,
            labelPadding: const EdgeInsets.all(0),
            tabs: getButtons(),
          )),
        ],
      ),
    );
  }

  List<Widget> getButtons() {
    return groups.map<Widget>((hash) {
      return ItemTypeMenuButton(hash);
    }).toList();
  }
}

class ItemTypeMenuButton extends StatelessWidget {
  final int categoryHash;

  const ItemTypeMenuButton(this.categoryHash);

  @override
  Widget build(BuildContext context) {
    return ManifestText<DestinyItemCategoryDefinition>(categoryHash,
        uppercase: true, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13));
  }
}
