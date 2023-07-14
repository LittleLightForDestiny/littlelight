import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/shared/blocs/context_menu_options/context_menu_options.bloc.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:provider/provider.dart';

class EquipLoadoutWidget extends StatelessWidget {
  final DestinyCharacterInfo character;
  final VoidCallback onClose;

  const EquipLoadoutWidget({
    Key? key,
    required this.character,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final classType = character.character.classType;
    if (classType == null) return SizedBox();
    return MenuBox(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuBoxTitle(
          "Loadout".translate(context),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ButtonStyle(visualDensity: VisualDensity.comfortable),
              child: Text("Equip".translate(context).toUpperCase()),
              onPressed: () async {
                final bloc = context.read<ContextMenuOptionsBloc>();
                bloc.openLoadoutTransfer(context, character, true);
                onClose();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(visualDensity: VisualDensity.comfortable),
              child: Text("Transfer".translate(context).toUpperCase()),
              onPressed: () {
                final bloc = context.read<ContextMenuOptionsBloc>();
                bloc.openLoadoutTransfer(context, character, false);
                onClose();
              },
            )
          ],
        ),
      ],
    ));
  }
}
