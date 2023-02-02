import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'base_tab_header.widget.dart';

class VaultTabHeaderWidget extends BaseTabHeaderWidget with DestinySettingsConsumer {
  VaultTabHeaderWidget();

  @override
  Widget buildBackground(BuildContext context) => Container(
          child: Image.asset(
        "assets/imgs/vault-secondary-special.jpg",
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
      ));

  @override
  Widget buildIcon(BuildContext context) => Image.asset(
        "assets/imgs/vault-secondary-overlay.png",
      );

  @override
  Widget buildProgressBar(BuildContext context) {
    final character = context.watch<ProfileBloc>().characters?.firstOrNull;
    if (character == null) return Container();
    final progressionHash = destinySettings.seasonalRankProgressionHash;
    final levelProg = character.progression?.progressions?["$progressionHash"];
    final overLevelProg =
        character.progression?.progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
    final fg = context.theme.upgradeLayers.layer0;
    final bg = Color.lerp(context.theme.upgradeLayers.layer1, Colors.black, .6);
    final currentProg = (levelProg?.level ?? 0) < (levelProg?.levelCap ?? 0) ? levelProg : overLevelProg;
    double completed = (currentProg?.progressToNextLevel ?? 0) / (currentProg?.nextLevelAt ?? 1);
    return Container(
      color: bg,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: completed,
        child: Shimmer.fromColors(
            baseColor: fg ?? Colors.transparent,
            period: Duration(seconds: 2),
            highlightColor: Colors.white,
            child: Container(
              color: Colors.white,
            )),
      ),
    );
  }
}
