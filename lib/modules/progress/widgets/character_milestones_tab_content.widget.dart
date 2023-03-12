import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/progress/widgets/milestone_item.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/character/character_info.widget.dart';
import 'package:little_light/shared/widgets/containers/height_keeper.widget.dart';
import 'package:little_light/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/widgets/multisection_scrollview/sliver_section.dart';

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
          SliverSection.fixedHeight(
            itemBuilder: (context, _) => CharacterInfoWidget(
              character,
              currencies: currencies,
            ),
            itemHeight: _characterInfoHeight,
          ),
          SliverSection.autoSize(
            itemBuilder: (context, index) {
              final milestone = milestones[index];
              final key = "character ${character.characterId} milestone ${milestone.milestoneHash}";
              return MilestoneItemWidget(
                milestone,
                key: Key(key),
              );
            },
            itemCount: milestones.length,
          )
        ],
        crossAxisSpacing: 50,
        mainAxisSpacing: 10,
        padding: const EdgeInsets.all(8).copyWith(top: 0),
        scrollViewKey: scrollViewKey,
      ),
    );
  }
}
