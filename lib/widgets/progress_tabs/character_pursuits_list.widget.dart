import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/progress_tabs/pursuit_item.widget.dart';

class CharacterPursuitsListWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();
  

  CharacterPursuitsListWidget({Key key, this.characterId}) : super(key: key);

  _CharacterPursuitsListWidgetState createState() =>
      _CharacterPursuitsListWidgetState();
}

class _CharacterPursuitsListWidgetState
    extends State<CharacterPursuitsListWidget>
    with AutomaticKeepAliveClientMixin {
  List<DestinyItemComponent> pursuits;
  StreamSubscription<NotificationEvent> subscription;
  bool fullyLoaded = false;

  @override
  void initState() {
    super.initState();
    getPursuits();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate && mounted) {
        getPursuits();
      }
    });  
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> getPursuits() async {
    var items = widget.profile.getCharacterInventory(widget.characterId);
    pursuits =
        items.where((i) => i.bucketHash == InventoryBucket.pursuits).toList();
    var pursuitHashes = items.map((i) => i.itemHash);
    var defs = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(pursuitHashes);
    pursuits.sort((itemA, itemB) => InventoryUtils.sortDestinyItems(
        itemA, itemB, widget.profile,
        sortingParams: [SortParameter(SortParameterType.tierType, -1)],
        defA: defs[itemA.itemHash],
        defB: defs[itemB.itemHash]));
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StaggeredGridView.countBuilder(
      crossAxisCount: 1,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemCount: (pursuits?.length ?? 0) + 1,
      padding: EdgeInsets.all(4).copyWith(top:0),
      mainAxisSpacing: 4,
      staggeredTileBuilder: (index){
        return StaggeredTile.fit(1);
      },
      itemBuilder: (context, index) {
        if (pursuits == null) return Container();
        if (index == 0) {
          return Container(
            height:96, 
            child:CharacterInfoWidget(
            key: Key("characterinfo_${widget.characterId}"),
            characterId: widget.characterId,
          ));
        }
        var item = pursuits[index - 1];
        return PursuitItemWidget(
          characterId: widget.characterId,
          item: item,
          key: Key("pursuit_${item.itemHash}"),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
