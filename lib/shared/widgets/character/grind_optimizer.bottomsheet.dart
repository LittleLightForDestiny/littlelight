import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu.bloc.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/menus/character_context_menu/grind_optimizer.widget.dart';
import 'package:little_light/shared/widgets/modals/base_bottom_sheet.base.dart';
import 'package:provider/provider.dart';

class GrindOptimizerBottomsheet extends BaseBottomSheet<int> {
  final DestinyCharacterInfo character;
  GrindOptimizerBottomsheet(this.character);

  @override
  Widget? buildHeader(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) => Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: MultiProvider(
          providers: [ChangeNotifierProvider(create: (context) => CharacterContextMenuBloc(context))],
          builder: (context, _) => SingleChildScrollView(
              padding: EdgeInsets.all(4) + context.mediaQuery.viewPadding.copyWith(top: 0),
              child: CharacterGrindOptimizerWidget(
                character: character,
                onClose: () => Navigator.pop(context),
              ))));
}
