import 'package:flutter/material.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_progress_list.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_pursuits_list.widget.dart';

class CharacterProgressTabWidget extends StatelessWidget {
  final String characterId;
  final TabController tabController;
  CharacterProgressTabWidget(this.characterId, {this.tabController});
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
            CharacterProgressListWidget(characterId:characterId),
            CharacterPursuitsListWidget(characterId: characterId)
          ],

        )),
      TabHeaderWidget(characterId),
    ]);
  }
}
