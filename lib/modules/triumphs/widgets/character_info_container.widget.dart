import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class CharacterInfoContainerWidget extends StatelessWidget {
  final Widget child;
  final DestinyCharacterInfo? character;
  const CharacterInfoContainerWidget(this.child, {Key? key, this.character}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final character = this.character;
    if (character == null) return child;
    final classDefinition = context.definition<DestinyClassDefinition>(character.character.classHash);
    return Container(
        margin: EdgeInsets.only(bottom: 4.0),
        child: Stack(children: [
          Positioned.fill(
            child: Container(
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: context.theme.surfaceLayers.layer3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                  character.character.emblemHash,
                  urlExtractor: (def) => def.secondarySpecial,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Row(children: [
                      Text(
                        character.getGenderedClassName(classDefinition),
                        style: context.textTheme.highlight,
                      )
                    ])),
                child
              ],
            ),
          )
        ]));
  }
}
