// @dart=2.9

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

typedef OnLoadoutSelect = void Function(LoadoutItemIndex loadout);

class LoadoutSelectSheet extends StatelessWidget {
  final DestinyCharacterComponent character;
  final List<LoadoutItemIndex> loadouts;

  final OnLoadoutSelect onSelect;
  final Widget header;

  const LoadoutSelectSheet({Key key, this.character, this.loadouts, this.header, this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Column(children: [
          header ?? Container(),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: loadouts
                            .map(
                              (loadout) => Container(
                                  color: LittleLightTheme.of(context).primaryLayers,
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Stack(children: [
                                    Positioned.fill(
                                        child: loadout.emblemHash != null
                                            ? ManifestImageWidget<DestinyInventoryItemDefinition>(
                                                loadout.emblemHash,
                                                fit: BoxFit.cover,
                                                urlExtractor: (def) {
                                                  return def?.secondarySpecial;
                                                },
                                              )
                                            : Container()),
                                    Container(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          loadout?.name?.toUpperCase() ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.fade,
                                          softWrap: false,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        )),
                                    Positioned.fill(
                                        child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          onSelect(loadout);
                                        },
                                      ),
                                    ))
                                  ])),
                            )
                            .toList(),
                      ))))
        ]));
  }
}
