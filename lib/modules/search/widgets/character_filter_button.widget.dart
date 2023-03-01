import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

typedef OnButtonTap = void Function();

class CharacterFilterButtonWidget extends StatelessWidget {
  final bool selected;
  final DestinyCharacterInfo character;
  final OnButtonTap? onTap;
  final OnButtonTap? onLongPress;
  const CharacterFilterButtonWidget(
    this.character, {
    Key? key,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer3,
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
            clipBehavior: Clip.antiAlias,
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
                Material(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.transparent,
                    child: InkWell(
                      enableFeedback: false,
                      onTap: onTap,
                      onLongPress: onLongPress,
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: context.theme.primaryLayers.layer0,
                                width: 3,
                                style: selected
                                    ? BorderStyle.solid
                                    : BorderStyle.none)),
                        constraints:
                            const BoxConstraints(minWidth: double.infinity),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        child: DefaultTextStyle(
                          style: context.textTheme.button,
                          child: Row(children: [
                            Container(
                              width: 36,
                              child: ManifestImageWidget<
                                  DestinyInventoryItemDefinition>(
                                character.character.emblemHash,
                                urlExtractor: (def) => def.secondaryOverlay,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 8),
                            ManifestText<DestinyClassDefinition>(
                              character.character.classHash,
                              textExtractor: (def) =>
                                  def.genderedClassNamesByGenderHash?[
                                      "${character.character.genderHash}"],
                              uppercase: true,
                            ),
                          ]),
                        ),
                      ),
                    )),
              ],
            )));
  }
}
