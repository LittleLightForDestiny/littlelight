import 'dart:async';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';

import 'package:little_light/widgets/item_list/character_info.widget.dart';

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
    var progressions =
        widget.profile.getCharacterProgression(widget.characterId).progressions;
    ranks = [
      progressions["${DestinyRanks.glory}"],
      progressions["${DestinyRanks.valor}"],
      progressions["${DestinyRanks.infamy}"]
    ];
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StaggeredGridView.countBuilder(
      crossAxisCount: 6,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemCount: (ranks?.length ?? 0) + 1,
      padding: EdgeInsets.all(4).copyWith(top: 0),
      mainAxisSpacing: 4,
      staggeredTileBuilder: (index) {
        if(index == 0){
          return StaggeredTile.extent(6, 96);
        }
        if(index < 4){
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
                key: Key("characterinfo_${widget.profile.lastUpdated}"),
                characterId: widget.characterId,
              ));
        }
        var item = ranks[index - 1];
        return RankItemWidget(
          characterId: widget.characterId,
          progression: item,
          key: Key("progression_${item.progressionHash}"),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => fullyLoaded ?? false;
}
