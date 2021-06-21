import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/models/loadout.dart';
import 'package:little_light/screens/equip_loadout.screen.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/base/base_destiny_stateful_item.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_details/section_header.widget.dart';

class ItemDetailLoadoutsWidget extends BaseDestinyStatefulItemWidget {
  final List<Loadout> loadouts;

  ItemDetailLoadoutsWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      this.loadouts})
      : super(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemDetailLoadoutsWidgetState();
  }
}

const _sectionId = "item_loadouts";

class ItemDetailLoadoutsWidgetState
    extends BaseDestinyItemState<ItemDetailLoadoutsWidget>
    with VisibleSectionMixin {
  @override
  String get sectionId => _sectionId;

  @override
  Widget build(BuildContext context) {
    if ((widget.loadouts?.length ?? 0) < 1) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8).copyWith(bottom: 4),
      child: Column(
        children: <Widget>[
          getHeader(
            TranslatedTextWidget(
              "Loadouts",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          visible ? Container(height: 8) : Container(),
          visible ? buildLoadouts(context) : Container()
        ],
      ),
    );
  }

  Widget buildLoadouts(BuildContext context) {
    var isTablet = MediaQueryHelper(context).tabletOrBigger;
    return StaggeredGridView.count(
        padding: EdgeInsets.all(0),
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        crossAxisCount: 3,
        staggeredTiles: widget.loadouts
            .map((item) => StaggeredTile.fit(isTablet ? 1 : 3))
            .toList(),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: widget.loadouts
            .map((item) => buildLoadoutItem(item, context))
            .toList());
  }

  Widget buildLoadoutItem(Loadout loadout, BuildContext context) {
    return Container(
        color: Theme.of(context).buttonColor,
        margin: EdgeInsets.only(bottom: 4),
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
              padding: EdgeInsets.all(16),
              child: Text(
                loadout?.name?.toUpperCase() ?? "",
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EquipLoadoutScreen(
                          loadout: loadout,
                        )));
              },
            ),
          ))
        ]));
  }
}
