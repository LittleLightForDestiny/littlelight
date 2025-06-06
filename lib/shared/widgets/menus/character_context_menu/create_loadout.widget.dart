import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/modals/context_menu_overlay/character_context_menu.bloc.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_info_box.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:provider/provider.dart';

class CreateLoadoutWidget extends StatelessWidget {
  final DestinyCharacterInfo character;

  const CreateLoadoutWidget({
    Key? key,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CharacterContextMenuBloc>();
    final classType = character.character.classType;
    if (classType == null) return SizedBox();
    return MenuBox(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuInfoBox(
          child: Column(
            children: [
              Row(children: [
                Expanded(child: Text("Create Loadout".translate(context))),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(
                    "Weapons".translate(context),
                    style: context.textTheme.button,
                  ),
                  SizedBox(width: 4),
                  LLSwitch.callback(
                    state.enableWeaponsInLoadouts,
                    (value) => state.enableWeaponsInLoadouts = value,
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Armor".translate(context),
                    style: context.textTheme.button,
                  ),
                  SizedBox(width: 4),
                  LLSwitch.callback(
                    state.enableArmorsInLoadouts,
                    (value) => state.enableArmorsInLoadouts = value,
                  ),
                ]),
              ]),
              SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text("Include Mods".translate(context))),
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(
                    "Weapons".translate(context),
                    style: context.textTheme.button,
                  ),
                  SizedBox(width: 4),
                  LLSwitch.callback(
                    state.includeWeaponMods,
                    (value) => state.includeWeaponMods = value,
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Armor".translate(context),
                    style: context.textTheme.button,
                  ),
                  SizedBox(width: 4),
                  LLSwitch.callback(
                    state.includeArmorMods,
                    (value) => state.includeArmorMods = value,
                  ),
                ]),
              ]),
            ],
          ),
        ),
        Row(children: [
          Expanded(
              child: ElevatedButton(
            style: ButtonStyle(visualDensity: VisualDensity.comfortable),
            child: Text("Equipped".translate(context).toUpperCase()),
            onPressed: () async {
              final bloc = context.read<CharacterContextMenuBloc>();
              bloc.openLoadoutCreation(context, character, true);
            },
          )),
          SizedBox(width: 4),
          Expanded(
              child: ElevatedButton(
            style: ButtonStyle(visualDensity: VisualDensity.comfortable),
            child: Text("All".translate(context).toUpperCase()),
            onPressed: () {
              final bloc = context.read<CharacterContextMenuBloc>();
              bloc.openLoadoutCreation(context, character, false);
            },
          )),
          // SizedBox(width: 4),
          // Expanded(
          //     child: ElevatedButton(
          //   style: ButtonStyle(visualDensity: VisualDensity.comfortable),
          //   child: Text("Destiny".translate(context).toUpperCase()),
          //   onPressed: () {
          //     final bloc = context.read<CharacterContextMenuBloc>();
          //     bloc.saveDestinyLoadout(context, character);
          //   },
          // ))
        ]),
      ],
    ));
  }
}
