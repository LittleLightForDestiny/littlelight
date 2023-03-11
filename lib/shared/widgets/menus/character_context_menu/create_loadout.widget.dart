import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/modules/loadouts/blocs/loadout_item_index.dart';
import 'package:little_light/modules/loadouts/pages/edit/edit_loadout.page_route.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/blocs/context_menu_options/context_menu_options.bloc.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:little_light/shared/widgets/ui/switch.dart';
import 'package:provider/provider.dart';

class CreateLoadoutWidget extends StatelessWidget {
  final DestinyCharacterInfo character;
  final VoidCallback onClose;

  const CreateLoadoutWidget({
    Key? key,
    required this.character,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ContextMenuOptionsBloc>();
    final classType = character.character.classType;
    if (classType == null) return SizedBox();
    return MenuBox(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuBoxTitle(
          "Create Loadout".translate(context),
          trailing: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
        Row(children: [
          Expanded(
              child: ElevatedButton(
            style: ButtonStyle(visualDensity: VisualDensity.comfortable),
            child: Text("Equipped".translate(context).toUpperCase()),
            onPressed: () async {
              final bloc = context.read<ContextMenuOptionsBloc>();
              bloc.openLoadoutCreation(context, character, true);
              onClose();
            },
          )),
          SizedBox(width: 4),
          Expanded(
              child: ElevatedButton(
            style: ButtonStyle(visualDensity: VisualDensity.comfortable),
            child: Text("All".translate(context).toUpperCase()),
            onPressed: () {
              final bloc = context.read<ContextMenuOptionsBloc>();
              bloc.openLoadoutCreation(context, character, false);
              onClose();
            },
          ))
        ]),
      ],
    ));
  }
}
