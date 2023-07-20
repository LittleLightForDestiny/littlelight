import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu.bloc.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu_view.dart';
import 'package:little_light/shared/widgets/tabs/custom_tab/custom_tab.dart';
import 'package:provider/provider.dart';

class CharacterContextMenuModalRoute extends RawDialogRoute {
  CharacterContextMenuModalRoute(
    CustomTabController characterTabController, {
    VoidCallback? onSearchTap,
    required List<DestinyCharacterInfo?> characters,
  }) : super(
          transitionDuration: Duration(milliseconds: 300),
          barrierColor: Colors.transparent,
          transitionBuilder: (context, animation, secondaryAnimation, child) => child,
          pageBuilder: (context, animation, secondaryAnimation) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (context) => CharacterContextMenuBloc(
                        context,
                        onSearchTap: onSearchTap,
                        characters: characters,
                        characterIndex: characterTabController.index,
                      )),
            ],
            builder: (context, _) => CharacterContextMenu(
              context.read<CharacterContextMenuBloc>(),
              context.watch<CharacterContextMenuBloc>(),
              charactersTabController: characterTabController,
              openAnimation: animation,
            ),
          ),
        );
}
