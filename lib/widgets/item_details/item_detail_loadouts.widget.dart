// @dart=2.9

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/core/blocs/loadouts/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/pages/equip/equip_loadout.page_route.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';

class ItemDetailLoadoutsWidget extends BaseDestinyStatefulItemWidget {
  final List<LoadoutItemIndex> loadouts;

  const ItemDetailLoadoutsWidget(
      DestinyItemComponent item, DestinyInventoryItemDefinition definition, DestinyItemInstanceComponent instanceInfo,
      {Key key, this.loadouts})
      : super(item: item, definition: definition, instanceInfo: instanceInfo, key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemDetailLoadoutsWidgetState();
  }
}

const _sectionId = "item_loadouts";

class ItemDetailLoadoutsWidgetState extends BaseDestinyItemState<ItemDetailLoadoutsWidget> with VisibleSectionMixin {
  @override
  String get sectionId => _sectionId;

  @override
  Widget build(BuildContext context) {
    if ((widget.loadouts?.length ?? 0) < 1) {
      return Container();
    }
    return Container(
      padding: const EdgeInsets.all(8).copyWith(bottom: 4),
      child: Column(
        children: <Widget>[
          getHeader(
            TranslatedTextWidget(
              "Loadouts",
              uppercase: true,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          visible ? Container(height: 8) : Container(),
          visible ? buildLoadouts(context) : Container()
        ],
      ),
    );
  }

  Widget buildLoadouts(BuildContext context) {
    return Container();
    // return StaggeredGrid.count(
    //   crossAxisCount: MediaQueryHelper(context).responsiveValue(1, tablet: 3),
    //   axisDirection: AxisDirection.down,
    //   crossAxisSpacing: 2,
    //   mainAxisSpacing: 2,
    //   children: widget.loadouts.map((e) => buildLoadoutItem(e, context)).toList(),
    // );
  }

  Widget buildLoadoutItem(LoadoutItemIndex loadout, BuildContext context) {
    return Container(
        color: LittleLightTheme.of(context).upgradeLayers,
        margin: const EdgeInsets.only(bottom: 4),
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
                Navigator.of(context).push(EquipLoadoutPageRoute(loadout.loadoutId));
              },
            ),
          ))
        ]));
  }
}
