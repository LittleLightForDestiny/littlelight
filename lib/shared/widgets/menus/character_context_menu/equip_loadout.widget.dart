import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/equipment/pages/context_menu_overlay/context_menu_options.bloc.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:provider/provider.dart';

class EquipLoadoutWidget extends StatelessWidget {
  final DestinyCharacterInfo character;

  const EquipLoadoutWidget({
    Key? key,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final classType = character.character.classType;
    if (classType == null) return SizedBox();
    return Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: context.theme.surfaceLayers.layer3,
          borderRadius: BorderRadius.circular(4),
        ),
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
                  style: ButtonStyle(visualDensity: VisualDensity.standard),
                  child: Text("Equip".translate(context).toUpperCase()),
                  onPressed: () async {
                    final bloc = context.read<ContextMenuOptionsBloc>();
                    bloc.openLoadoutTransfer(context, character, true);
                  },
                ),
                Container(height: 4),
                ElevatedButton(
                  style: ButtonStyle(visualDensity: VisualDensity.standard),
                  child: Text("Transfer".translate(context).toUpperCase()),
                  onPressed: () {
                    final bloc = context.read<ContextMenuOptionsBloc>();
                    bloc.openLoadoutTransfer(context, character, false);
                  },
                ),
                Container(height: 4),
                ElevatedButton(
                  style: ButtonStyle(visualDensity: VisualDensity.standard),
                  child: Text("Random".translate(context).toUpperCase()),
                  onPressed: () {
                    final bloc = context.read<ContextMenuOptionsBloc>();
                    bloc.openEquipRandomLoadout(context, character);
                  },
                ),
              ],
            ),
          ],
        ));
  }
}
