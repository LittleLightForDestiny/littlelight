import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_progress_list.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_pursuits_list.widget.dart';

class CharacterProgressTabWidget extends StatelessWidget {
  final DestinyCharacterComponent character;
  final TabController tabController;
  CharacterProgressTabWidget(this.character, {this.tabController});
  @override
  
  @override
  Widget build(BuildContext context) {
    var screenPadding = MediaQuery.of(context).padding;
    var topOffset = screenPadding.top + kToolbarHeight;
    var bottomOffset = screenPadding.bottom + kToolbarHeight;
    return Stack(children: [
      Positioned.fill(
        top:topOffset,
        bottom:bottomOffset,
        child: 
        TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            CharacterProgressListWidget(characterId:character.characterId),
            CharacterPursuitsListWidget(characterId: character.characterId)
          ],

        )),
      TabHeaderWidget(character),
    ]);
  }
}
