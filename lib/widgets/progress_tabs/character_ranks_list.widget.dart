import 'dart:async';
import 'dart:math';

import 'package:bungie_api/models/destiny_faction_progression.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/services/littlelight/littlelight_data.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/item_list/character_info.widget.dart';
import 'package:little_light/widgets/progress_tabs/faction_rank_item.widget.dart';
import 'package:little_light/widgets/progress_tabs/rank_item.widget.dart';

class CharacterRanksListWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  CharacterRanksListWidget({Key key, this.characterId}) : super(key: key);

  _CharacterRanksListWidgetState createState() =>
      _CharacterRanksListWidgetState();
}

class _CharacterRanksListWidgetState extends State<CharacterRanksListWidget>
    with AutomaticKeepAliveClientMixin {
  List<DestinyProgression> ranks;
  List<DestinyFactionProgression> progressions;
  StreamSubscription<NotificationEvent> subscription;
  bool fullyLoaded = false;

  @override
  void initState() {
    super.initState();
    getRanks();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate && mounted) {
        getRanks();
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> getRanks() async {
    var progressionsRoot =
        widget.profile.getCharacterProgression(widget.characterId);
    var gameData = await LittleLightDataService().getGameData();
    ranks = [
      progressionsRoot.progressions["${gameData.ranks.glory}"],
      progressionsRoot.progressions["${gameData.ranks.valor}"],
      progressionsRoot.progressions["${gameData.ranks.infamy}"]
    ];
    this.progressions = progressionsRoot.factions.values
        .where((p) => p.factionHash != null)
        .toList();
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
      padding: EdgeInsets.all(4).copyWith(
          top: 0,
          left: max(screenPadding.left, 4),
          right: max(screenPadding.right, 4)),
      crossAxisCount: 6,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemCount: (ranks?.length ?? 0) + (progressions?.length ?? 0) + 1,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      staggeredTileBuilder: (index) {
        if (index == 0) {
          return StaggeredTile.extent(6, 112);
        }
        if (index < 4) {
          return StaggeredTile.count(2, 3);
        }
        return StaggeredTile.extent(6, 96);
      },
      itemBuilder: (context, index) {
        if (ranks == null) return Container();
        if (index == 0) {
          return Container(
              height: 96,
              child: CharacterInfoWidget(
                key: Key("characterinfo_${widget.characterId}"),
                characterId: widget.characterId,
              ));
        }
        if (index < ranks.length + 1) {
          var rank = ranks[index - 1];
          return RankItemWidget(
            characterId: widget.characterId,
            progression: rank,
            key: Key("rank_${rank.progressionHash}"),
          );
        }
        var progression = progressions[index - ranks.length - 1];
        return FactionRankItemWidget(
          characterId: widget.characterId,
          progression: progression,
          key: Key("progression_${progression.progressionHash}"),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
