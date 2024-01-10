import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/loadouts/pages/home/destiny_loadouts.bloc.dart';
import 'package:little_light/modules/loadouts/widgets/destiny_loadout_list_item.widget.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/multisection_scrollview.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/base_scrollable_section.dart';
import 'package:little_light/shared/widgets/multisection_scrollview/sections/intrinsic_height_scrollable_section.dart';

class DestinyLoadoutsView extends StatelessWidget {
  final DestinyLoadoutsBloc bloc;
  final DestinyLoadoutsBloc state;
  const DestinyLoadoutsView({
    super.key,
    required this.bloc,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final characters = state.characters;
    if (characters == null) return Container();
    if (characters.isEmpty) return Container();
    return MultiSectionScrollView(
      [
        for (final c in characters) ...buildCharacterLoadouts(context, c),
      ],
      padding: EdgeInsets.all(4),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
    );
  }

  List<ScrollableSection> buildCharacterLoadouts(BuildContext context, DestinyCharacterInfo character) {
    final loadouts = state.getLoadoutsFromCharacter(character);
    if (loadouts == null) return [];
    if (loadouts.isEmpty) return [];
    return [
      IntrinsicHeightScrollSection(
        itemBuilder: (context, index) {
          final loadout = loadouts[index];
          return DestinyLoadoutListItemWidget(
            loadouts[index],
            character: character,
            onTap: () => bloc.openLoadout(loadout),
          );
        },
        itemsPerRow: MediaQueryHelper(context).responsiveValue<int>(1, tablet: 2, desktop: 3),
        itemCount: loadouts.length,
      ),
    ];
  }
}
