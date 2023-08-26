import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/character/base_character_icon.widget.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:provider/provider.dart';

extension on DestinyClass {
  String? get iconAssetPath {
    switch (this) {
      case DestinyClass.Titan:
        return "assets/imgs/class_titan_bordered.png";
      case DestinyClass.Hunter:
        return "assets/imgs/class_hunter_bordered.png";
      case DestinyClass.Warlock:
        return "assets/imgs/class_warlock_bordered.png";
      default:
        return null;
    }
  }
}

class CharacterIconWidget extends BaseCharacterIconWidget {
  final DestinyCharacterInfo character;
  final bool hideClassIcon;

  const CharacterIconWidget(
    this.character, {
    double borderWidth = characterIconDefaultBorderWidth,
    this.hideClassIcon = false,
  }) : super(
          borderWidth: borderWidth,
        );

  @override
  Widget buildIcon(BuildContext context) => ManifestImageWidget<DestinyInventoryItemDefinition>(
        character.character.emblemHash,
      );

  @override
  List<Positioned>? buildOverlays(BuildContext context) {
    if (hideClassIcon) return null;
    final iconPath = character.character.classType?.iconAssetPath;
    if (iconPath == null) return null;
    final profile = context.watch<ProfileBloc>();
    final isPlaying = profile.isPlaying && profile.lastPlayedCharacter?.characterId == this.character.characterId;
    return [
      if (isPlaying)
        Positioned(
          child: Container(
              margin: EdgeInsets.all(borderWidth * 2),
              decoration: CornerBadgeDecoration(
                colors: [context.theme.achievementLayers.layer1],
                badgeSize: 12.0,
                position: CornerPosition.TopLeft,
              )),
        ),
      Positioned(
        left: borderWidth * 2,
        bottom: borderWidth * 2,
        child: Container(
          height: 18,
          width: 18,
          alignment: Alignment.bottomCenter,
          child: Container(
            child: Image.asset(
              iconPath,
            ),
          ),
        ),
      ),
    ];
  }
}
