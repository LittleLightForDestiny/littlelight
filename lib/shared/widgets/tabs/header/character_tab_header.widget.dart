import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/profile/destiny_settings.consumer.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:shimmer/shimmer.dart';
import 'base_tab_header.widget.dart';

class CharacterTabHeaderWidget extends BaseTabHeaderWidget with DestinySettingsConsumer {
  final DestinyCharacterInfo character;

  CharacterTabHeaderWidget(this.character);

  @override
  Widget buildBackground(BuildContext context) => ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.character.emblemHash,
        urlExtractor: ((definition) => definition.secondarySpecial),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      );

  @override
  Widget buildIcon(BuildContext context) {
    return ManifestImageWidget<DestinyInventoryItemDefinition>(
      character.character.emblemHash,
      urlExtractor: ((definition) => definition.secondaryOverlay),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget buildProgressBar(BuildContext context) {
    final progressionHash = destinySettings.seasonalRankProgressionHash;
    final levelProg = character.progression?.progressions?["$progressionHash"];
    final overLevelProg =
        character.progression?.progressions?["${destinySettings.seasonalPrestigeRankProgressionHash}"];
    final fg = context.theme.upgradeLayers.layer0;
    final bg = Color.lerp(context.theme.upgradeLayers.layer0, Colors.black, .6);
    final currentProg = (levelProg?.level ?? 0) < (levelProg?.levelCap ?? 0) ? levelProg : overLevelProg;
    double completed = (currentProg?.progressToNextLevel ?? 0) / (currentProg?.nextLevelAt ?? 1);
    return Container(
      color: bg,
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: completed,
        child: Shimmer.fromColors(
            baseColor: fg,
            period: const Duration(seconds: 2),
            highlightColor: Colors.white,
            child: Container(
              color: Colors.white,
            )),
      ),
    );
  }
}
