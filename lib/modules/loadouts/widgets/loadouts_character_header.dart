import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class LoadoutCharacterHeaderWidget extends StatelessWidget {
  final DestinyCharacterInfo character;
  LoadoutCharacterHeaderWidget(this.character, {super.key});

  @override
  Widget build(BuildContext context) {
    final classDef = context.definition<DestinyClassDefinition>(character.character.classHash);
    final raceDef = context.definition<DestinyRaceDefinition>(character.character.raceHash);
    final className = character.getGenderedClassName(classDef);
    final raceName = character.getGenderedRaceName(raceDef);
    return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            Positioned.fill(
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(
              character.character.emblemHash,
              urlExtractor: (def) => def.secondarySpecial,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
            )),
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                        character.character.emblemHash,
                        fit: BoxFit.cover,
                      )),
                  Container(
                    width: 4,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(className, style: context.textTheme.itemNameHighDensity),
                      Container(height: 2),
                      Text(raceName, style: context.textTheme.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
