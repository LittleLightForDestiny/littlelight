import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/progress/widgets/core_activity_rank.widget.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/blocs/bucket_options/bucket_options.bloc.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/character/character_info.widget.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sliver_section.dart';
import 'package:provider/provider.dart';

const _characterInfoHeight = 128.0;

class RanksCharacterTabContentWidget extends StatelessWidget with ManifestConsumer {
  final DestinyCharacterInfo character;
  final List<DestinyItemComponent>? currencies;
  final List<DestinyProgression>? coreProgressions;
  final Key? scrollViewKey;

  ItemSectionOptionsBloc sectionOptionsState(BuildContext context) => context.watch<ItemSectionOptionsBloc>();

  const RanksCharacterTabContentWidget(
    this.character, {
    Key? key,
    this.currencies,
    this.coreProgressions,
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
          buildMainRanks(context),
        ],
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        padding: const EdgeInsets.all(8).copyWith(top: 0) +
            EdgeInsets.only(
              left: context.mediaQuery.padding.left,
              right: context.mediaQuery.padding.right,
            ),
        scrollViewKey: scrollViewKey,
      ),
    );
  }

  ScrollableSection buildMainRanks(BuildContext context) {
    return FixedHeightScrollSection(
      128,
      itemBuilder: (context, index) {
        final progression = coreProgressions?[index];
        if (progression == null) return Container();
        return CoreActivityRankItemWidget(progression);
      },
      itemCount: coreProgressions?.length ?? 0,
      itemsPerRow: context.mediaQuery.responsiveValue(1, tablet: 2, laptop: 3),
    );
  }
}
