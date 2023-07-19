import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/modules/equipment/pages/context_menu_overlay/context_menu_options.bloc.dart';
import 'package:little_light/core/blocs/selection/selection.bloc.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/shared/widgets/inventory_item/low_density_inventory_item.dart';
import 'package:little_light/shared/widgets/containers/menu_box.dart';
import 'package:little_light/shared/widgets/containers/menu_box_title.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

class CharacterPostmasterOptionsWidget extends StatelessWidget {
  final DestinyCharacterInfo character;

  const CharacterPostmasterOptionsWidget({
    Key? key,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final postmasterItems = context.watch<ContextMenuOptionsBloc>().getPostmasterItems(character.characterId);
    if (postmasterItems.isEmpty) return Container();
    return MenuBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      MenuBoxTitle(
        "Postmaster".translate(context),
        trailing: ManifestText<DestinyInventoryBucketDefinition>(
          InventoryBucket.lostItems,
          textExtractor: (def) => "${postmasterItems.length}/${def.itemCount}",
          style: context.textTheme.button,
        ),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: postmasterItems
              .map((e) => Container(
                    width: 64,
                    height: 64,
                    margin: EdgeInsets.only(left: 2),
                    child: LowDensityInventoryItem(e),
                  ))
              .toList(),
        ),
      ),
      Container(height: 4),
      ElevatedButton(
        style: ButtonStyle(visualDensity: VisualDensity.comfortable),
        child: Text("Select all".translate(context).toUpperCase()),
        onPressed: () {
          context.read<SelectionBloc>().selectItems(postmasterItems);
          Navigator.of(context).pop();
        },
      ),
    ]));
  }
}
