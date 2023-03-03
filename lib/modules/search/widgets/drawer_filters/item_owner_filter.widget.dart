import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/modules/search/blocs/filter_options/item_owner_filter_options.dart';
import 'package:little_light/modules/search/widgets/drawer_filters/filter_button.widget.dart';
import 'package:little_light/shared/utils/extensions/character_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:provider/provider.dart';

import 'base_drawer_filter.widget.dart';

enum _NonCharacterOwners { Vault, Profile }

class ItemOwnerFilterWidget extends BaseDrawerFilterWidget<ItemOwnerFilterOptions> {
  @override
  Widget buildTitle(BuildContext context) {
    return Text("Location".translate(context).toUpperCase());
  }

  @override
  Widget buildOptions(BuildContext context, ItemOwnerFilterOptions data) {
    final selectedCharacters = data.value.characters;
    final characters = context.watch<ProfileBloc>().characters;
    final availableCharacters = characters?.where((c) => data.availableValues.characters.contains(c.characterId)) ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
            children: availableCharacters
                .map((char) => FilterButtonWidget(
                      Row(children: [
                        Container(
                          width: 36,
                          child: ManifestImageWidget<DestinyInventoryItemDefinition>(
                            char.character.emblemHash,
                            urlExtractor: (def) => def.secondaryOverlay,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 8),
                        ManifestText<DestinyClassDefinition>(
                          char.character.classHash,
                          textExtractor: (def) => def.genderedClassNamesByGenderHash?["${char.character.genderHash}"],
                          uppercase: true,
                        ),
                      ]),
                      background: ManifestImageWidget<DestinyInventoryItemDefinition>(
                        char.character.emblemHash,
                        urlExtractor: (def) => def.secondarySpecial,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                      selected: selectedCharacters.contains(char.characterId),
                      onTap: () => updateCharacter(context, data, char.characterId, false),
                      onLongPress: () => updateCharacter(context, data, char.characterId, true),
                    ))
                .toList()),
        Row(
          children: [
            if (data.availableValues.vault)
              Expanded(
                child: FilterButtonWidget(
                  buildNonCharacterFilterButtonContent(
                    context,
                    Image.asset("assets/imgs/vault-secondary-overlay.png"),
                    Text("Vault".translate(context).toUpperCase()),
                  ),
                  background: Image.asset(
                    "assets/imgs/vault-secondary-special.jpg",
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                  selected: data.value.vault,
                  onTap: () => updateNonCharacterOptions(context, data, _NonCharacterOwners.Vault, false),
                  onLongPress: () => updateNonCharacterOptions(context, data, _NonCharacterOwners.Vault, true),
                ),
              ),
            if (data.availableValues.profile)
              Expanded(
                child: FilterButtonWidget(
                  buildNonCharacterFilterButtonContent(
                      context,
                      ManifestImageWidget<DestinyInventoryItemDefinition>(
                        profileCharacterEmblemHash,
                        urlExtractor: (def) => def.secondaryOverlay,
                        fit: BoxFit.contain,
                      ),
                      Text("Profile".translate(context).toUpperCase())),
                  background: ManifestImageWidget<DestinyInventoryItemDefinition>(
                    profileCharacterEmblemHash,
                    urlExtractor: (def) => def.secondarySpecial,
                    fit: BoxFit.cover,
                    alignment: Alignment.centerLeft,
                  ),
                  selected: data.value.profile,
                  onTap: () => updateNonCharacterOptions(context, data, _NonCharacterOwners.Profile, false),
                  onLongPress: () => updateNonCharacterOptions(context, data, _NonCharacterOwners.Profile, true),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void updateCharacter(BuildContext context, ItemOwnerFilterOptions data, String? characterId, bool forceAdd) {
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

  void updateNonCharacterOptions(
      BuildContext context, ItemOwnerFilterOptions data, _NonCharacterOwners option, bool forceAdd) {
    final value = data.value.clone();

    final multiselect = forceAdd || data.value.length > 1;
    final isSelected = option == _NonCharacterOwners.Vault ? value.vault : value.profile;
    if (multiselect && !isSelected) {
      option == _NonCharacterOwners.Vault ? value.vault = true : value.profile = true;
    } else if (isSelected) {
      option == _NonCharacterOwners.Vault ? value.vault = false : value.profile = false;
    } else {
      value.clear();
      option == _NonCharacterOwners.Vault ? value.vault = true : value.profile = true;
    }
    update(context, ItemOwnerFilterOptions(value));
  }

  Widget buildNonCharacterFilterButtonContent(BuildContext context, Widget icon, Widget label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(child: icon, width: 36, height: 36),
        SizedBox(width: 8),
        Expanded(child: label),
      ],
    );
  }
}
