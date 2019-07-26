import 'dart:async';

import 'package:bungie_api/models/destiny_color.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_talent_grid_component.dart';
import 'package:bungie_api/models/destiny_talent_grid_definition.dart';
import 'package:bungie_api/models/destiny_talent_node_category.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';

class AnimatedCharacterBackgroundWidget extends StatefulWidget {
  final TabController tabController;
  final NotificationService broadcaster = NotificationService();
  AnimatedCharacterBackgroundWidget({
    this.tabController,
    Key key,
  }) : super(key: key);

  @override
  _AnimatedCharacterBackgroundWidgetState createState() =>
      _AnimatedCharacterBackgroundWidgetState();
}

class _CharacterInfo {
  final DestinyColor emblemColor;
  final int characterClass;
  final int damageType;
  final String path;
  _CharacterInfo(
      {this.emblemColor, this.characterClass, this.damageType, this.path});
}

class _AnimatedCharacterBackgroundWidgetState
    extends State<AnimatedCharacterBackgroundWidget>
    with SingleTickerProviderStateMixin {
  List<_CharacterInfo> characters;
  AnimationController _controller;
  DecorationTween tween;
  StreamSubscription<NotificationEvent> subscription;

  @override
  void initState() {
    super.initState();
    tween = DecorationTween(begin: BoxDecoration(), end: BoxDecoration());
    updateCharacters();
    widget.tabController.addListener(characterChangedListener);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
    subscription = widget.broadcaster.listen((event) {
      if (!mounted) return;
      if (event.type == NotificationType.receivedUpdate || event.type == NotificationType.localUpdate) {
        updateCharacters();
      }
    });
  }

  updateCharacters() async {
    var _characters = ProfileService().getCharacters();
    characters = [];
    for (var c in _characters) {
      var equipment = ProfileService().getCharacterEquipment(c.characterId);
      var subclass =
          equipment.firstWhere((i) => i.bucketHash == InventoryBucket.subclass);
      var subclassDef = await ManifestService()
          .getDefinition<DestinyInventoryItemDefinition>(subclass.itemHash);
      var talentGridDef = await ManifestService()
          .getDefinition<DestinyTalentGridDefinition>(
              subclassDef.talentGrid.talentGridHash);
      var talentGrid = ProfileService().getTalentGrid(subclass.itemInstanceId);
      var talentGridCat =
          extractTalentGridNodeCategory(talentGrid, talentGridDef);

      characters.add(_CharacterInfo(
          emblemColor: c.emblemColor,
          characterClass: c.classType,
          damageType: subclassDef.talentGrid?.hudDamageType,
          path: talentGridCat?.identifier));
    }
    characterChangedListener();
  }

  DestinyTalentNodeCategory extractTalentGridNodeCategory(
      DestinyItemTalentGridComponent talentGrid,
      DestinyTalentGridDefinition talentGridDef) {
    Iterable<int> activatedNodes = talentGrid.nodes
        .where((node) => node.isActivated)
        .map((node) => node.nodeIndex);
    Iterable<DestinyTalentNodeCategory> selectedSkills =
        talentGridDef.nodeCategories.where((category) {
      var overlapping = category.nodeHashes
          .where((nodeHash) => activatedNodes.contains(nodeHash));
      return overlapping.length > 0;
    }).toList();
    DestinyTalentNodeCategory subclassPath = selectedSkills
        .firstWhere((nodeDef) => nodeDef.isLoreDriven, orElse: () => null);
    return subclassPath;
  }

  @override
  dispose() {
    super.dispose();
    widget.tabController.removeListener(characterChangedListener);
    subscription.cancel();
  }

  characterChangedListener() {
    Color emblemColor;
    Color subclassColor;
    var character = widget.tabController.index < characters.length
        ? characters[widget.tabController.index]
        : null;
    if (character != null) {
      emblemColor = Color.fromARGB(255, character.emblemColor.red,
          character.emblemColor.green, character.emblemColor.blue);
      subclassColor = DestinyData.getDamageTypeColor(character.damageType);
    } else {
      emblemColor = Colors.black;
      subclassColor = Colors.grey.shade800;
    }

    tween = DecorationTween(
        begin: tween.lerp(_controller.value),
        end: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            Color.lerp(emblemColor, Colors.grey.shade900, .5),
            Color.fromARGB(255, 100, 100, 115),
            Color.lerp(subclassColor, Colors.grey.shade900, .5),
          ],
          begin: FractionalOffset(.3, .1),
          end: FractionalOffset(.7, .9),
        )));
    _controller.reset();
    _controller.forward();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      decoration: tween.animate(_controller),
      child: Container(),
    );
  }

  
}
