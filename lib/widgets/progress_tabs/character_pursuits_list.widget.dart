import 'dart:async';
import 'dart:math';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_category_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/progress_tabs/bounty_item.widget.dart';

class CharacterPursuitsListWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  CharacterPursuitsListWidget({Key key, this.characterId}) : super(key: key);

  _CharacterPursuitsListWidgetState createState() =>
      _CharacterPursuitsListWidgetState();
}

enum _PursuitListItemType {
  CharacterInfo,
  Header,
  Quest,
  Container,
  Bounty,
  Other
}

class _PursuitListItem {
  final _PursuitListItemType type;
  final int hash;
  final String label;
  final DestinyItemComponent item;

  _PursuitListItem(this.type, {this.hash, this.item, this.label});
}

class _CharacterPursuitsListWidgetState
    extends State<CharacterPursuitsListWidget>
    with AutomaticKeepAliveClientMixin {
  List<_PursuitListItem> items;
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
    var allItems = widget.profile.getCharacterInventory(widget.characterId);
    var pursuits = allItems
        .where((i) => i.bucketHash == InventoryBucket.pursuits)
        .toList();
    var pursuitHashes = pursuits.map((i) => i.itemHash);
    var defs = await widget.manifest
        .getDefinitions<DestinyInventoryItemDefinition>(pursuitHashes);
    pursuits.sort((itemA, itemB) => InventoryUtils.sortDestinyItems(
        itemA, itemB,
        sortingParams: UserSettingsService().pursuitOrdering,
        defA: defs[itemA.itemHash],
        defB: defs[itemB.itemHash]));

    List<DestinyItemComponent> questSteps = [];
    List<DestinyItemComponent> bounties = [];
    Map<String, List<DestinyItemComponent>> other = {};

    pursuits?.forEach((p) {
      var def = defs[p.itemHash];
      if (def?.itemCategoryHashes?.contains(16) ?? false) {
        questSteps.add(p);
        return;
      }
      if ((def?.itemCategoryHashes?.contains(1784235469) ?? false) ||
          (def?.inventory?.stackUniqueLabel?.contains("bounties") ?? false) ||
          (def?.inventory?.stackUniqueLabel?.contains("story") ?? false)) {
        bounties.add(p);
        return;
      }
      if (other[def.itemTypeDisplayName] == null) {
        other[def.itemTypeDisplayName] = [];
      }
      other[def.itemTypeDisplayName].add(p);
    });

    items = [_PursuitListItem(_PursuitListItemType.CharacterInfo)];

    if (questSteps.length > 0) {
      items.add(_PursuitListItem(_PursuitListItemType.Header, hash: 53));
      items.addAll(questSteps
          .map((q) => _PursuitListItem(_PursuitListItemType.Quest, item: q)));
    }
    if (bounties.length > 0) {
      items
          .add(_PursuitListItem(_PursuitListItemType.Header, hash: 1784235469));
      items.addAll(bounties
          .map((q) => _PursuitListItem(_PursuitListItemType.Bounty, item: q)));
    }

    other.forEach((k, v) {
      items.add(_PursuitListItem(_PursuitListItemType.Header, label: k));
      v.forEach((p){
        items.add(_PursuitListItem(_PursuitListItemType.Other, item:p));
      });
    });

    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var screenPadding = MediaQuery.of(context).padding;
    return StaggeredGridView.countBuilder(
        crossAxisCount: 30,
        crossAxisSpacing: 4,
        addRepaintBoundaries: true,
        itemCount: (items?.length ?? 0),
        padding: EdgeInsets.all(4).copyWith(top: 0, left: max(screenPadding.left, 4), right: max(screenPadding.right, 4)),
        mainAxisSpacing: 4,
        staggeredTileBuilder: (index) => tileBuilder(context, index),
        itemBuilder: itemBuilder);
  }

  StaggeredTile tileBuilder(BuildContext context, int index) {
    var item = items[index];
    var isTablet = MediaQueryHelper(context).tabletOrBigger;
    switch (item.type) {
      case _PursuitListItemType.CharacterInfo:
        return StaggeredTile.extent(30, 112);
        break;
      case _PursuitListItemType.Header:
        return StaggeredTile.extent(30, 40);
        break;
      case _PursuitListItemType.Quest:
        if (isTablet) {
          return StaggeredTile.extent(10, 150);
        }
        return StaggeredTile.extent(30, 150);
      
      case _PursuitListItemType.Container:
      case _PursuitListItemType.Bounty:
      case _PursuitListItemType.Other:
        if (isTablet) {
          return StaggeredTile.extent(6, 132);
        }
        return StaggeredTile.extent(15, 132);
    }
    return StaggeredTile.count(3, 2);
  }

  Widget itemBuilder(BuildContext context, int index) {
    var item = items[index];
    switch (item.type) {
      case _PursuitListItemType.CharacterInfo:
        return CharacterInfoWidget(
          key: Key("characterinfo_${widget.characterId}"),
          characterId: widget.characterId,
        );
        break;
      case _PursuitListItemType.Header:
        Widget field;
        TextStyle style = TextStyle(fontWeight: FontWeight.bold);
        if (item.hash != null) {
          field = ManifestText<DestinyItemCategoryDefinition>(
            item.hash,
            uppercase: true,
            style: style,
          );
        }else if((item.label?.length ?? 0) > 0){
          field = Text(
            item.label.toUpperCase(),
            style: style,
          );
        }else{
          field = TranslatedTextWidget("Other", uppercase: true, style: style,);
        }
        return HeaderWidget(child: field, alignment: Alignment.centerLeft,);
        break;
      case _PursuitListItemType.Quest:
        // return PursuitItemWidget(
        //     characterId: widget.characterId,
        //     item: item.item,
        //     key: Key("pursuit_${item.item?.itemHash}_${item.item?.itemInstanceId}_${widget.characterId}"));
        // break;
      case _PursuitListItemType.Other:
      case _PursuitListItemType.Container:
      case _PursuitListItemType.Bounty:
        return BountyItemWidget(
            characterId: widget.characterId,
            item: item.item,
            key: Key("pursuit_${item.item?.itemHash}_${item.item?.itemInstanceId}_${widget.characterId}"));
    }

    return Container();
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
