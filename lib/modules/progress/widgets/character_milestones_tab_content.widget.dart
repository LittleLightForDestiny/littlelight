import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/progress/widgets/milestone_item.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/character/character_info.widget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';

const _characterInfoHeight = 128.0;

class CharacterMilestonesTabContentWidget extends StatelessWidget with ManifestConsumer {
  final DestinyCharacterInfo character;
  final List<DestinyMilestone> milestones;
  final List<DestinyItemComponent>? currencies;
  final Key? scrollViewKey;

  const CharacterMilestonesTabContentWidget(
    this.character, {
    Key? key,
    required this.milestones,
    this.currencies,
    this.scrollViewKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      key: Key("character_tab_${character.characterId}"),
      builder: (context, constraints) => MultiSectionScrollView(
        [
          FixedHeightScrollSection(
            _characterInfoHeight,
            itemBuilder: (context, _) => CharacterInfoWidget(
              character,
              currencies: currencies,
            ),
          ),
          IntrinsicHeightScrollSection(
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              final key = "character ${character.characterId} milestone ${milestone.milestoneHash}";
              return MilestoneItemWidget(
                milestone,
                key: Key(key),
              );
            },
            itemCount: milestones.length,
            itemsPerRow: context.mediaQuery.responsiveValue(1, tablet: 2, desktop: 3),
          )
        ],
        crossAxisSpacing: context.mediaQuery.responsiveValue(8, tablet: 16),
        mainAxisSpacing: context.mediaQuery.responsiveValue(8, tablet: 16),
        padding: EdgeInsets.all(context.mediaQuery.responsiveValue<double>(8.0, tablet: 16.0)).copyWith(top: 0),
        scrollViewKey: scrollViewKey,
      ),
    );
  }
}
