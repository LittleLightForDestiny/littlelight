import 'package:flutter/material.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/progress_tabs/character_progress_list.widget.dart';

class CharacterProgressTabWidget extends StatelessWidget {
  final String characterId;
  CharacterProgressTabWidget(this.characterId);
  @override
  
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      TabHeaderWidget(characterId),
      Positioned.fill(
        top:getListTopOffset(context),
        child: CharacterProgressListWidget(characterId:characterId),)
    ]);
  }

  double getListTopOffset(BuildContext context) {
    double paddingTop = MediaQuery.of(context).padding.top;
    return paddingTop + kToolbarHeight + 2;
  }
}
