import 'package:flutter/material.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_pursuits_list.widget.dart';

class CharacterPursuitsTabWidget extends StatelessWidget {
  final String characterId;
  CharacterPursuitsTabWidget(this.characterId);
  @override
  
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        top:getListTopOffset(context),
        child: CharacterPursuitsListWidget(characterId:characterId),),
        TabHeaderWidget(characterId),
    ]);
  }

  double getListTopOffset(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return paddingTop + kToolbarHeight + 2;
  }
}
