import 'dart:async';
import 'dart:math';

import 'package:bungie_api/enums/damage_type_enum.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:bungie_api/models/destiny_lore_definition.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:bungie_api/models/destiny_socket_category_definition.dart';
import 'package:bungie_api/models/destiny_stat_definition.dart';
import 'package:bungie_api/models/destiny_stat_group_definition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:bungie_api/enums/destiny_socket_category_style_enum.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/inventory_utils.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class ShareImageWidget extends StatelessWidget {
  final DestinyInventoryItemDefinition definition;
  final Map<int, DestinySocketCategoryDefinition> socketCategoryDefinitions;
  final Map<int, DestinyInventoryItemDefinition> plugItemDefinitions;
  final Map<int, DestinyStatDefinition> statDefinitions;
  final List<DestinyItemSocketState> itemSockets;
  final DestinyItemInstanceComponent instanceInfo;
  final Map<int, int> statValues;
  final Map<int, int> masterworkValues;
  final DestinyStatGroupDefinition statGroupDefinition;
  final DestinyLoreDefinition loreDefinition;
  final DestinyObjectiveProgress masterworkObjective;
  final DestinyObjectiveDefinition masterworkObjectiveDefinition;
  final Function onLoad;

  ShareImageWidget(
      {Key key,
      this.definition,
      this.socketCategoryDefinitions,
      this.plugItemDefinitions,
      this.statDefinitions,
      this.itemSockets,
      this.instanceInfo,
      this.statValues,
      this.masterworkValues,
      this.statGroupDefinition,
      this.loreDefinition,
      this.masterworkObjective,
      this.masterworkObjectiveDefinition,
      this.onLoad})
      : super(key: key);

  static Future<ShareImageWidget> builder(BuildContext context,
      {DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      Function onLoad}) async {
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
    DestinyObjectiveProgress masterworkObjective;
    DestinyObjectiveDefinition masterworkObjectiveDefinition;
    var plugItemDefinitions = await manifest
        .getDefinitions<DestinyInventoryItemDefinition>(modHashes.toSet());
    Set<int> statHashes = new Set();
    Map<int, int> statValues = Map();
    Map<int, int> masterworkValues = Map();
    definition.investmentStats.forEach((s) {
      statValues[s.statTypeHash] = s.value;
    });
    if (itemSockets != null) {
      for (var socket in itemSockets) {
        if (socket.plugObjectives != null) {
          for (var objective in socket.plugObjectives) {
            if (objective.visible) {
              masterworkObjective = objective;
              masterworkObjectiveDefinition =
                  await manifest.getDefinition<DestinyObjectiveDefinition>(
                      objective.objectiveHash);
            }
          }
        }
        var plugDef = plugItemDefinitions[socket.plugHash];
        if (plugDef == null) continue;
        plugDef.investmentStats?.forEach((stat) {
          if (!statValues.containsKey(stat.statTypeHash)) {
            statValues[stat.statTypeHash] = 0;
          }
          statValues[stat.statTypeHash] += stat.value;
          if (plugDef.plug?.uiPlugLabel == 'masterwork') {
            if (!masterworkValues.containsKey(stat.statTypeHash)) {
              masterworkValues[stat.statTypeHash] = 0;
            }
            masterworkValues[stat.statTypeHash] += stat.value;
          }
        });
      }
    } else {
      definition.sockets.socketEntries.forEach((socket) {
        var plugDef = plugItemDefinitions[socket.singleInitialItemHash];
        plugDef.investmentStats.forEach((stat) {
          statValues[stat.statTypeHash] += stat.value;
        });
      });
    }
    statHashes.addAll(definition.investmentStats.map((s) => s.statTypeHash));
    for (var plugDef in plugItemDefinitions.values) {
      statHashes.addAll(plugDef.investmentStats?.map((s) => s.statTypeHash) ?? []);
    }

    var statDefinitions =
        await manifest.getDefinitions<DestinyStatDefinition>(statHashes);
    var statGroupDefinition;
    if (definition?.stats?.statGroupHash != null) {
      statGroupDefinition =
          await manifest.getDefinition<DestinyStatGroupDefinition>(
              definition.stats.statGroupHash);
    }

    var loreDefinition;
    if (definition.loreHash != null) {
      loreDefinition = await manifest
          .getDefinition<DestinyLoreDefinition>(definition.loreHash);
    }

    return ShareImageWidget(
      definition: definition,
      socketCategoryDefinitions: socketCategoryDefinitions,
      plugItemDefinitions: plugItemDefinitions,
      statDefinitions: statDefinitions,
      itemSockets: itemSockets,
      instanceInfo: instanceInfo,
      statGroupDefinition: statGroupDefinition,
      statValues: statValues,
      masterworkValues: masterworkValues,
      loreDefinition: loreDefinition,
      masterworkObjective: masterworkObjective,
      masterworkObjectiveDefinition: masterworkObjectiveDefinition,
      onLoad: onLoad,
    );
  }

  @override
  build(BuildContext context) {
    return Container(
        width: 1920,
        height: 1080,
        color: Colors.blueGrey.shade300,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: buildHeaderBackground(context)),
            buildItemInfo(context),
            buildItemStats(context),
            buildItemLore(context)
          ],
        ));
  }

  Widget buildHeaderBackground(BuildContext context) {
    return Image(
      image: AdvancedNetworkImage(BungieApiService.url(definition.screenshot),
          loadedCallback: () {
        print('loaded');
        onLoad();
      }, loadedFromDiskCacheCallback: () {
        onLoad();
      }),
      fit: BoxFit.none,
    );
  }

  Widget buildItemInfo(BuildContext context) {
    double left = 148;
    if (loreDefinition != null) {
      left += 250;
    }
    return Positioned(
        left: left,
        top: 114,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildMainItemInfo(context),
            Container(height: 20),
            buildDescription(context),
            Container(height: 20),
            buildPerks(context),
            Container(height: 20),
            buildMods(context),
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
        modifiersLabel(
          context,
          Text(
            perksCatDefinition.displayProperties.name,
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(.6)),
          ),
        ),
        Container(height: 16),
        buildPerksGrid(context, perksCatDefinition),
      ],
    );
  }

  Widget modifiersLabel(BuildContext context, Widget title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        title,
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
      if (socket.reusablePlugs == null) {
        if (socket.plugHash != null) {
          return Column(children:[buildPerkIcon(context, socket.plugHash, true)]);
        } else {
          return Container(width: 72, height: 72, margin: EdgeInsets.all(4));
        }
      }
      return Column(
          children: socket.reusablePlugs
              .where((s) => s.enabled)
              .map((s) => buildPerkIcon(
                  context, s.plugItemHash, s.plugItemHash == socket.plugHash))
              .toList());
    }
    return Container(width: 72, height: 72, margin: EdgeInsets.all(4));
  }

  Widget buildPerkIcon(BuildContext context, int plugHash, bool selected) {
    var def = plugItemDefinitions[plugHash];
    var plugIcon =
        AdvancedNetworkImage(BungieApiService.url(def.displayProperties.icon));
    if (def.plug?.plugCategoryIdentifier?.contains('intrinsic') ?? false) {
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
        modifiersLabel(
          context,
          Text(
            modsCatDefinition.displayProperties.name,
            style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(.6)),
          ),
        ),
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
    if (instanceInfo?.primaryStat == null) {
      return Container();
    }
    int statValue = instanceInfo.primaryStat.value;
    int statHash = definition.stats.primaryBaseStatHash;
    var def = statDefinitions[statHash];
    if (statValue == null) {
      statValue = definition.stats.stats["$statHash"].value;
    }
    bool showDamageType = [DamageType.Arc,DamageType.Thermal, DamageType.Void].contains(instanceInfo.damageType);
    return Container(
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
        Row(children: [
          showDamageType ? Icon(
            DestinyData.getDamageTypeIcon(instanceInfo.damageType),
            color:DestinyData.getDamageTypeColor(instanceInfo.damageType),
            size:50
            ) : Container(),
          Text(
            "$statValue",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 50),
          ),
        ]),
        Text(
          def.displayProperties.name.toUpperCase(),
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        Container(height: 20),
        buildMasterworkCounter()
      ]),
    );
  }

  Widget buildMasterworkCounter() {
    if (this.masterworkObjective == null) {
      return Container();
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          child: Row(
            children: <Widget>[
              Container(
                width: 20,
                height: 20,
                child: Image(
                    image: AdvancedNetworkImage(BungieApiService.url(
                        masterworkObjectiveDefinition.displayProperties.icon))),
              ),
              Container(
                width: 4,
              ),
              Text(masterworkObjectiveDefinition.progressDescription,
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              Container(
                width: 4,
              ),
              Text("${masterworkObjective.progress}",
                  style: TextStyle(color: Colors.amber.shade200, fontSize: 15)),
            ],
          )),
      Container(
        height: 90,
        child: Image.asset('assets/imgs/masterwork-icon.png'),
      )
    ]);
  }

  Widget buildStats(BuildContext context) {
    List<int> statHashes = statGroupDefinition.scaledStats.map((s)=>s.statHash).toList();
    List<int> noBarStats = statGroupDefinition.scaledStats.where((s)=>s.displayAsNumeric).map((s)=>s.statHash).toList();
    statHashes.addAll(DestinyData.hiddenStats);
    statHashes.sort((statA, statB) {
      int valA = noBarStats.contains(statA)
          ? 2
          : DestinyData.hiddenStats.contains(statA) ? 1 : 0;
      int valB = noBarStats.contains(statB)
          ? 2
          : DestinyData.hiddenStats.contains(statB) ? 1 : 0;
      return valA - valB;
    });
    return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: statHashes.map((h) => buildStat(context, h)).toList());
  }

  Widget buildStat(BuildContext context, int hash) {
    var statDef = statDefinitions[hash];
    var value = statValues[hash];
    var masterworkValue = masterworkValues[hash] ?? 0;
    value = value - masterworkValue;
    var scaled = statGroupDefinition.scaledStats
        .firstWhere((s) => s.statHash == hash, orElse: () => null);
    var max = statGroupDefinition.maximumValue;
    if (scaled != null) {
      value = InventoryUtils.interpolateStat(
          statValues[hash], scaled.displayInterpolation);

      if (masterworkValue > 0) {
        var finalValue = InventoryUtils.interpolateStat(
            statValues[hash] + masterworkValue, scaled.displayInterpolation);
        masterworkValue = finalValue - value;
      }
      max = scaled.maximumValue;
    }
    var hideBar = scaled?.displayAsNumeric ?? DestinyData.noBarStats.contains(hash);
    return Container(
        padding: EdgeInsets.only(bottom: 4),
        child: Row(
          children: <Widget>[
            Text(statDef.displayProperties.name,
                style: TextStyle(fontSize: 16)),
            Container(width: 8),
            Container(
                alignment: Alignment.topCenter,
                width: 40,
                child: Text(
                  "$value",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: masterworkValue > 0
                          ? Colors.amber
                          : Colors.grey.shade300),
                )),
            Container(width: 8),
            buildStatBar(context, hash, value, max, masterworkValue, hideBar)
          ],
        ));
  }

  Widget buildStatBar(BuildContext context, int hash, int value, int maxValue,
      int masterworkValue, bool hideBar) {
    if (hideBar) {
      return Container(width: 240, height: 18);
    }
    maxValue = max(maxValue, value);
    return Container(
        width: 240,
        height: 18,
        color: Colors.black.withOpacity(.4),
        child: Row(
          children: <Widget>[
            Container(
                color: Colors.grey.shade300,
                width: ((value - masterworkValue) / maxValue) * 240,
                height: 18),
            masterworkValue != null
                ? Container(
                    color: Colors.amber,
                    width: (masterworkValue / maxValue) * 240,
                    height: 18)
                : Container()
          ],
        ));
  }

  Widget buildPerkDetails(BuildContext context) {
    var perksCatDefinition = socketCategoryDefinitions.values.firstWhere((def) {
      return def.categoryStyle & DestinySocketCategoryStyle.Reusable ==
          DestinySocketCategoryStyle.Reusable;
    }, orElse: () => null);
    if (perksCatDefinition == null) return Container();
    return Container(
      color: Colors.blueGrey.shade800,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HeaderWidget(
            alignment: Alignment.centerLeft,
            child: Text(
              perksCatDefinition.displayProperties.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(height: 16),
          buildPerksDetailsGrid(context, perksCatDefinition)
        ],
      ),
    );
  }

  Widget buildPerksDetailsGrid(
      BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == def.hash,
        orElse: () => null);
    List<Widget> columns = [];
    socketCategory.socketIndexes.forEach((index) {
      if (isSocketVisible(index)) {
        columns.add(buildPerkDetailColumn(context, index));
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

  Widget buildPerkDetailColumn(BuildContext context, int socketIndex) {
    if (itemSockets != null) {
      var socket = itemSockets[socketIndex];
      return Flexible(
          flex: 1,
          child: Column(
              children: socket.reusablePlugs
                  .where((s) => s.enabled)
                  .map((s) => buildPerkDetailInfo(context, s.plugItemHash,
                      s.plugItemHash == socket.plugHash))
                  .toList()));
    }
    return Container();
  }

  Widget buildPerkDetailInfo(
      BuildContext context, int plugHash, bool selected) {
    var def = plugItemDefinitions[plugHash];

    var infoWidget = Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  def.displayProperties.name.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  def.displayProperties.description,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                )
              ],
            )));

    var plugIcon =
        AdvancedNetworkImage(BungieApiService.url(def.displayProperties.icon));
    if (def.plug.plugCategoryIdentifier.contains('intrinsic')) {
      return Container(
          margin: EdgeInsets.all(4),
          child: Row(children: [
            Container(
              width: 72,
              height: 72,
              child: Image(image: plugIcon),
            ),
            infoWidget
          ]));
    }
    return Container(
        margin: EdgeInsets.all(4),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: selected
                  ? Color.fromRGBO(121, 172, 206, 1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
            ),
            foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border:
                    Border.all(width: 2, color: Colors.white.withOpacity(.6))),
            width: 72,
            height: 72,
            child: Image(image: plugIcon),
          ),
          infoWidget
        ]));
  }

  Widget buildModDetails(BuildContext context) {
    var modsCatDefinition = socketCategoryDefinitions.values.firstWhere((def) {
      return def.categoryStyle & DestinySocketCategoryStyle.Consumable ==
          DestinySocketCategoryStyle.Consumable;
    }, orElse: () => null);
    if (modsCatDefinition == null) return Container();
    return Container(
      color: Colors.blueGrey.shade800,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HeaderWidget(
            alignment: Alignment.centerLeft,
            child: Text(
              modsCatDefinition.displayProperties.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Container(height: 16),
          buildModDetailsGrid(context, modsCatDefinition)
        ],
      ),
    );
  }

  Widget buildModDetailsGrid(
      BuildContext context, DestinySocketCategoryDefinition def) {
    var socketCategory = definition.sockets.socketCategories.firstWhere(
        (s) => s.socketCategoryHash == def.hash,
        orElse: () => null);
    List<Widget> columns = [];
    socketCategory.socketIndexes.forEach((index) {
      if (isSocketVisible(index)) {
        columns.add(buildModDetailColumn(context, index));
        columns.add(Container(
          width: 2,
          color: Colors.white.withOpacity(.6),
          margin: EdgeInsets.symmetric(horizontal: 12),
        ));
      }
    });
    columns.removeLast();
    return IntrinsicHeight(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: columns.toList()));
  }

  Widget buildModDetailColumn(BuildContext context, int socketIndex) {
    double maxWidth = 356;
    if (itemSockets != null) {
      var socket = itemSockets[socketIndex];
      return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: buildModDetailInfo(context, socket.plugHash));
    }
    return Container();
  }

  Widget buildModDetailInfo(BuildContext context, int plugHash) {
    var def = plugItemDefinitions[plugHash];

    var infoWidget = Expanded(
        child: Container(
            margin: EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  def.displayProperties.name.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  def.displayProperties.description,
                  softWrap: true,
                )
              ],
            )));

    var plugIcon =
        AdvancedNetworkImage(BungieApiService.url(def.displayProperties.icon));
    return Container(
        margin: EdgeInsets.all(4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.grey.shade300)),
            width: 96,
            height: 96,
            child: Image(image: plugIcon),
          ),
          infoWidget
        ]));
  }

  Widget buildItemLore(BuildContext context) {
    if (definition?.loreHash == null) return Container();
    return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        width: 350,
        child: Container(
          color: Colors.black.withOpacity(.6),
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(height: 108),
              HeaderWidget(
                alignment: Alignment.centerLeft,
                child: TranslatedTextWidget("Lore",
                    uppercase: true,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(height: 16),
              Expanded(
                  child: Container(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        loreDefinition.displayProperties.description
                            .replaceAll('\n\n', '\n'),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w300),
                      )))
            ],
          ),
        ));
  }
}
