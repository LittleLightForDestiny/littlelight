import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';


typedef void OnLoadoutSelect(Loadout loadout);

class LoadoutSelectSheet extends StatelessWidget {
  final DestinyCharacterComponent character;
  final List<Loadout> loadouts;

  final ManifestService manifest = ManifestService();
  final OnLoadoutSelect onSelect;
  final Widget header;

  LoadoutSelectSheet(
      {Key key, this.character, this.loadouts, this.header, this.onSelect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child:Column(children: [
      header ?? Container(),
      Expanded(
          child: SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: loadouts
                        .map(
                          (loadout) => Container(
                              color: Theme.of(context).buttonColor,
                              margin: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Stack(children: [
                                Positioned.fill(
                                    child: loadout.emblemHash != null
                                        ? ManifestImageWidget<
                                            DestinyInventoryItemDefinition>(
                                            loadout.emblemHash,
                                            fit: BoxFit.cover,
                                            urlExtractor: (def) {
                                              return def?.secondarySpecial;
                                            },
                                          )
                                        : Container()),
                                Container(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      loadout?.name?.toUpperCase() ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
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
