import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_owner_filter_options.dart';
import 'package:little_light/modules/search/widgets/filter_button.widget.dart';
import 'package:little_light/shared/widgets/character/character_icon.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

import 'base_drawer_filter.widget.dart';
import 'character_filter_button.widget.dart';

enum _NonCharacterOwners { Vault, Profile }

class ItemOwnerFilterWidget
    extends BaseDrawerFilterWidget<ItemOwnerFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Slot".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, ItemOwnerFilterOptions data) {
    final selectedCharacters = data.value.characters;
    final characters = context.watch<ProfileBloc>().characters;
    final availableCharacters = characters?.where(
            (c) => data.availableValues.characters.contains(c.characterId)) ??
        [];
    return Column(children: [
      Column(
          children: availableCharacters
              .map((char) => CharacterFilterButtonWidget(
                    char,
                    selected: selectedCharacters.contains(char.characterId),
                    onTap: () =>
                        updateCharacter(context, data, char.characterId, false),
                    onLongPress: () =>
                        updateCharacter(context, data, char.characterId, true),
                  ))
              .toList()),
      Row(
        children: [
          FilterButtonWidget(Column(
            children: [],
          ))
        ],
      ),
    ]);
  }

  void updateCharacter(BuildContext context, ItemOwnerFilterOptions data,
      String? characterId, bool forceAdd) {
    if (characterId == null) return;
    final value = data.value.clone();
    final characters = value.characters;
    final multiselect = forceAdd || data.value.length > 1;
    final isSelected = characters.contains(characterId);
    if (multiselect && !isSelected) {
      characters.add(characterId);
    } else if (isSelected) {
      characters.remove(characterId);
    } else {
      value.clear();
      characters.add(characterId);
    }
    update(context, ItemOwnerFilterOptions(value));
  }

  void updateNonCharacterOptions(BuildContext context,
      ItemOwnerFilterOptions data, _NonCharacterOwners option, bool forceAdd) {
    final value = data.value.clone();

    final multiselect = forceAdd || data.value.length > 1;
    final isSelected =
        option == _NonCharacterOwners.Vault ? value.vault : value.profile;
    if (multiselect && !isSelected) {
      option == _NonCharacterOwners.Vault
          ? value.vault = true
          : value.profile = true;
    } else if (isSelected) {
      option == _NonCharacterOwners.Vault
          ? value.vault = false
          : value.profile = false;
    } else {
      value.clear();
      option == _NonCharacterOwners.Vault
          ? value.vault = true
          : value.profile = true;
    }
    update(context, ItemOwnerFilterOptions(value));
  }
}
