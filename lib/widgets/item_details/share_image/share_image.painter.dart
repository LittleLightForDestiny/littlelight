import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:bungie_api/enums/destiny_socket_category_style_enum.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';

class ShareImageWidget extends StatelessWidget {
  final DestinyInventoryItemDefinition definition;
  final Map<int, DestinySocketCategoryDefinition> socketCategoryDefinitions;
  final Map<int, DestinyInventoryItemDefinition> plugItemDefinitions;
  final Map<int, DestinyStatDefinition> statDefinitions;
  final List<DestinyItemSocketState> itemSockets;
  final DestinyItemInstanceComponent instanceInfo;
  final Map<int, int> statValues;

  ShareImageWidget(
      {Key key,
      this.definition,
      this.socketCategoryDefinitions,
      this.plugItemDefinitions,
      this.statDefinitions,
      this.itemSockets,
      this.instanceInfo, this.statValues})
      : super(key: key);

  static Future<ShareImageWidget> builder(BuildContext context,
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition}) async {
    ManifestService manifest = ManifestService();
    var socketCategoryHashes =
        definition.sockets.socketCategories.map((s) => s.socketCategoryHash);
    var socketCategoryDefinitions = await manifest
        .getDefinitions<DestinySocketCategoryDefinition>(socketCategoryHashes);

    Set<int> modHashes = new Set();

    definition.sockets.intrinsicSockets.forEach((s) {
      modHashes.add(s.plugItemHash);
    });
    definition.sockets.socketEntries.forEach((s) {
      modHashes.addAll(s.reusablePlugItems.map((r) => r.plugItemHash));
      modHashes.add(s.singleInitialItemHash);
    });

    List<DestinyItemSocketState> itemSockets;
    DestinyItemInstanceComponent instanceInfo;

    if (item != null) {
      instanceInfo = ProfileService().getInstanceInfo(item.itemInstanceId);
      itemSockets = ProfileService().getItemSockets(item.itemInstanceId);
      itemSockets.forEach((s) {
        if (s.reusablePlugHashes != null) {
          modHashes.addAll(s.reusablePlugHashes);
        }
        if (s.plugHash != null) {
          modHashes.add(s.plugHash);
        }
      });
    }
    var plugItemDefinitions = await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(modHashes.toSet());
    Set<int> statHashes = new Set();
    Map<int, int> statValues = Map();
    definition.investmentStats.forEach((s){
      statValues[s.statTypeHash] = s.value;
    });
    if(itemSockets != null){
      itemSockets.forEach((socket){
        var plugDef = plugItemDefinitions[socket.plugHash];
        if(plugDef == null) return;
        plugDef.investmentStats.forEach((stat){
          statValues[stat.statTypeHash] += stat.value;
        });
      });
    }else{
      definition.sockets.socketEntries.forEach((socket){
        var plugDef = plugItemDefinitions[socket.singleInitialItemHash];
        plugDef.investmentStats.forEach((stat){
          statValues[stat.statTypeHash] = stat.value;
        });
      });
    }
    statHashes.addAll(definition.investmentStats.map((s) => s.statTypeHash));
    for (var plugDef in plugItemDefinitions.values) {
      statHashes.addAll(plugDef.investmentStats.map((s) => s.statTypeHash));
    }

    var statDefinitions =
        await manifest.getDefinitions<DestinyStatDefinition>(statHashes);

    return ShareImageWidget(
        definition: definition,
        socketCategoryDefinitions: socketCategoryDefinitions,
        plugItemDefinitions: plugItemDefinitions,
        statDefinitions: statDefinitions,
        itemSockets: itemSockets,
        instanceInfo: instanceInfo,
        statValues:statValues);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1920,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[buildHeader(context)]));
  }

  buildHeader(BuildContext context) {
    return Container(
        width: 1920,
        height: 1080,
        color: Colors.red,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: buildHeaderBackground(context)),
            buildItemInfo(context),
            buildItemStats(context)
          ],
        ));
  }

  Widget buildHeaderBackground(BuildContext context) {
    return Image(
      image: AdvancedNetworkImage(BungieApiService.url(definition.screenshot)),
      fit: BoxFit.none,
    );
  }

  Widget buildItemInfo(BuildContext context) {
    return Positioned(
        left: 148,
        top: 114,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildMainItemInfo(context),
            Container(height: 40),
            buildDescription(context),
            Container(height: 40),
            buildPerks(context),
            Container(height: 40),
            buildMods(context)
          ],
        ));
  }

  Widget buildMainItemInfo(BuildContext context) {
    return Row(
      children: <Widget>[
        buildItemIcon(context),
        Container(
          width: 24,
        ),
        buildNameAndType(context)
      ],
    );
  }

  Widget buildItemIcon(BuildContext context) {
    return Container(
        height: 90,
        width: 90,
        decoration:
            BoxDecoration(border: Border.all(width: 3, color: Colors.white)),
        child: Image(
          image: AdvancedNetworkImage(
              BungieApiService.url(definition.displayProperties.icon)),
          fit: BoxFit.cover,
        ));
  }

  Widget buildNameAndType(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          definition.displayProperties.name.toUpperCase(),
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
        ),
        Text(
          definition.itemTypeDisplayName.toUpperCase(),
          style: TextStyle(
              color: Colors.white.withOpacity(.6),
              fontSize: 36,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget buildDescription(BuildContext context) {
    return Container(
        width: 730,
        child: Text(
          definition.displayProperties.description,
          style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300),
        ));
  }

  Widget buildPerks(BuildContext context) {
    var perksCatDefinition = socketCategoryDefinitions.values.firstWhere((def) {
      return def.categoryStyle & DestinySocketCategoryStyle.Reusable ==
          DestinySocketCategoryStyle.Reusable;
    }, orElse: () => null);
    if (perksCatDefinition == null) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        modifiersLabel(context, perksCatDefinition),
        Container(height: 16),
        buildPerksGrid(context, perksCatDefinition),
      ],
    );
  }

  Widget modifiersLabel(
      BuildContext context, DestinySocketCategoryDefinition def) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          def.displayProperties.name,
          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(.6)),
        ),
        Container(
          height: 8,
        ),
        Container(
          height: 3,
          width: 730,
          color: Colors.white.withOpacity(.6),
        )
      ],
    );
  }

  Widget buildPerksGrid(
      BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == def.hash,
        orElse: () => null);
    List<Widget> columns = [];
    socketCategory.socketIndexes.forEach((index) {
      if (isSocketVisible(index)) {
        columns.add(buildPerkColumn(context, index));
        columns.add(Container(
          width: 2,
          color: Colors.white.withOpacity(.6),
          margin: EdgeInsets.symmetric(horizontal: 12),
        ));
      }
    });
    columns.removeLast();
    return IntrinsicHeight(
        child: Container(
            width: 730,
            child: Stack(children: [
              Positioned.fill(
                  child: Image.asset(
                'assets/imgs/perks_grid.png',
                repeat: ImageRepeat.repeat,
                alignment: Alignment(-.5, 0),
              )),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: columns.toList())
            ])));
  }

  bool isSocketVisible(int index) {
    if (itemSockets != null) {
      return itemSockets[index].isVisible;
    }
    return true;
  }

  Widget buildPerkColumn(BuildContext context, int socketIndex) {
    if (itemSockets != null) {
      var socket = itemSockets[socketIndex];
      return Column(
          children: socket.reusablePlugs
              .where((s) => s.enabled)
              .map((s) => buildPerkIcon(
                  context, s.plugItemHash, s.plugItemHash == socket.plugHash))
              .toList());
    }
    return Container(
        width: 72, height: 72, margin: EdgeInsets.all(4), color: Colors.blue);
  }

  Widget buildPerkIcon(BuildContext context, int plugHash, bool selected) {
    var def = plugItemDefinitions[plugHash];
    var plugIcon =
        AdvancedNetworkImage(BungieApiService.url(def.displayProperties.icon));
    if (def.plug.plugCategoryIdentifier.contains('intrinsic')) {
      return Container(
        width: 72,
        height: 72,
        margin: EdgeInsets.all(4),
        child: Image(image: plugIcon),
      );
    }
    return Container(
      width: 72,
      height: 72,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: selected ? Color.fromRGBO(121, 172, 206, 1) : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(width: 2, color: Colors.white.withOpacity(.6))),
      child: Image(image: plugIcon),
    );
  }

  Widget buildMods(BuildContext context) {
    var modsCatDefinition = socketCategoryDefinitions.values.firstWhere((def) {
      return def.categoryStyle & DestinySocketCategoryStyle.Consumable ==
          DestinySocketCategoryStyle.Consumable;
    }, orElse: () => null);
    if (modsCatDefinition == null) return Container();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        modifiersLabel(context, modsCatDefinition),
        Container(height: 16),
        buildModsRow(context, modsCatDefinition)
      ],
    );
  }

  Widget buildModsRow(
      BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == def.hash,
        orElse: () => null);
    List<Widget> intrinsics = definition.sockets.intrinsicSockets
        .map((s) => buildModIcon(context, s.plugItemHash))
        .toList();
    List<Widget> columns = socketCategory.socketIndexes
        .where((i) => isSocketVisible(i))
        .map((index) {
          if (itemSockets != null) {
            return itemSockets[index].plugHash;
          }
          return definition.sockets.socketEntries[index].singleInitialItemHash;
        })
        .map((index) => buildModIcon(context, index))
        .toList()
        .reversed
        .toList();
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: intrinsics + columns);
  }

  Widget buildModIcon(BuildContext context, int plugHash) {
    var def = plugItemDefinitions[plugHash];
    var plugIcon =
        AdvancedNetworkImage(BungieApiService.url(def.displayProperties.icon));
    return Container(
      width: 96,
      height: 96,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: Colors.grey.shade400)),
      child: Image(image: plugIcon),
    );
  }

  Widget buildItemStats(BuildContext context) {
    return Positioned(
        right: 152,
        bottom: 100,
        child: IntrinsicHeight(
            child: Row(children: [
          buildPrimaryStat(context),
          Container(
              color: Colors.white.withOpacity(.6),
              width: 2,
              margin: EdgeInsets.symmetric(horizontal: 16)),
          buildStats(context)
        ])));
  }

  Widget buildPrimaryStat(BuildContext context) {
    int statValue = instanceInfo.primaryStat.value;
    int statHash = definition.stats.primaryBaseStatHash;
    var def = statDefinitions[statHash];
    if (statValue == null) {
      statValue = definition.stats.stats["$statHash"].value;
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
        Text(
          "$statValue",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 50),
        ),
        Text(
          def.displayProperties.name.toUpperCase(),
          style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(.6)),
        )
      ]),
    );
  }

  Widget buildStats(BuildContext context) {
    List<int> statHashes = [];
    for(var hash in DestinyData.statWhitelist){
      // implement stat filtering
      
    }
    return Column(
      children: definition.investmentStats.map((s)=>buildStat(context, s.statTypeHash)).toList()
    );
  }

  Widget buildStat(BuildContext context, int hash){
    var statDef =statDefinitions[hash];
    return Row(children: <Widget>[
      Text(statDef.displayProperties.name),
      Text("${statValues[hash]}")
    ],);
  }
}
