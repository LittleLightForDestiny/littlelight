// @dart=2.9

import 'dart:async';

import 'package:bungie_api/models/destiny_faction_progression.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';
import 'package:little_light/widgets/progress_tabs/rank_item.widget.dart';

import 'faction_rank_item.widget.dart';

class CharacterRanksListWidget extends StatefulWidget {
  final String characterId;

  CharacterRanksListWidget({Key key, this.characterId}) : super(key: key);

  _CharacterRanksListWidgetState createState() => _CharacterRanksListWidgetState();
}

class _CharacterRanksListWidgetState extends State<CharacterRanksListWidget>
    with AutomaticKeepAliveClientMixin, LittleLightDataConsumer, ProfileConsumer {
  List<DestinyProgression> ranks;
  List<DestinyFactionProgression> progressions;
  bool fullyLoaded = false;

  @override
  void initState() {
    super.initState();
    getRanks();
    profile.addListener(getRanks);
  }

  @override
  dispose() {
    profile.removeListener(getRanks);
    super.dispose();
  }

  Future<void> getRanks() async {
    var progressionsRoot = profile.getCharacterProgression(widget.characterId);
    var gameData = await littleLightData.getGameData();
    ranks = [
      progressionsRoot.progressions["${gameData.ranks.glory}"],
      progressionsRoot.progressions["${gameData.ranks.valor}"],
      progressionsRoot.progressions["${gameData.ranks.infamy}"]
    ];
    this.progressions = progressionsRoot.factions.values.where((p) => p.factionHash != null).toList();
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (ranks == null || progressions == null) return LoadingAnimWidget();
    var screenPadding = MediaQuery.of(context).padding;
    return MultiSectionScrollView(
      [
        SliverSection(
            itemCount: 1,
            itemHeight: 112,
            itemBuilder: (context, index) => CharacterInfoWidget(
                  key: Key("characterinfo_${widget.characterId}"),
                  characterId: widget.characterId,
                )),
        SliverSection(
            itemCount: ranks.length,
            itemsPerRow: 3,
            itemAspectRatio: .6,
            itemBuilder: (context, index) {
              final rank = ranks[index];
              return RankItemWidget(
                characterId: widget.characterId,
                progression: rank,
                key: Key("rank_${rank.progressionHash}"),
              );
            }),
        SliverSection(
            itemCount: progressions.length,
            itemsPerRow: 1,
            itemHeight: 96,
            itemBuilder: (context, index) {
              final progression = progressions[index];
              return FactionRankItemWidget(
                characterId: widget.characterId,
                progression: progression,
                key: Key("progression_${progression.progressionHash}"),
              );
            })
      ],
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      padding: EdgeInsets.all(4) + screenPadding.copyWith(top: 0, bottom: 0),
    );
    // return StaggeredGrid.count(
    // padding: EdgeInsets.all(4).copyWith(
    //     top: 0,
    //     left: max(screenPadding.left, 4),
    //     right: max(screenPadding.right, 4)),
    // crossAxisCount: 6,
    // addAutomaticKeepAlives: true,
    // addRepaintBoundaries: true,
    // itemCount: (ranks?.length ?? 0) + (progressions?.length ?? 0) + 1,
    // mainAxisSpacing: 4,
    // crossAxisSpacing: 4,
    // staggeredTileBuilder: (index) {
    //   if (index == 0) {
    //     return StaggeredGridTile.extent(crossAxisCellCount:6, mainAxisExtent:112);
    //   }
    //   if (index < 4) {
    //     return StaggeredGridTile.count(2, 3);
    //   }
    //   return StaggeredGridTile.extent(crossAxisCellCount:6, mainAxisExtent:96);
    // },
    // itemBuilder: (context, index) {
    //   if (ranks == null) return Container();
    //   if (index == 0) {
    //     return Container(
    //         height: 96,
    //         child: CharacterInfoWidget(
    //           key: Key("characterinfo_${widget.characterId}"),
    //           characterId: widget.characterId,
    //         ));
    //   }
    //   if (index < ranks.length + 1) {
    //     var rank = ranks[index - 1];
    //     return RankItemWidget(
    //       characterId: widget.characterId,
    //       progression: rank,
    //       key: Key("rank_${rank.progressionHash}"),
    //     );
    //   }
    //   var progression = progressions[index - ranks.length - 1];
    //   return FactionRankItemWidget(
    //     characterId: widget.characterId,
    //     progression: progression,
    //     key: Key("progression_${progression.progressionHash}"),
    //   );
    // },
    // );
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
