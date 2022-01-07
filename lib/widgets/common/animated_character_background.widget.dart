import 'dart:async';
import 'dart:ui';

import 'package:bungie_api/enums/damage_type.dart';
import 'package:bungie_api/enums/destiny_class.dart';
import 'package:bungie_api/models/destiny_color.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';

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
  final DestinyClass characterClass;
  final DamageType damageType;
  _CharacterInfo({this.emblemColor, this.characterClass, this.damageType});
}

class _AnimatedCharacterBackgroundWidgetState
    extends State<AnimatedCharacterBackgroundWidget>
    with SingleTickerProviderStateMixin, ProfileConsumer, ManifestConsumer {
  List<_CharacterInfo> characters;
  AnimationController _controller;
  ColorTween tween;
  StreamSubscription<NotificationEvent> subscription;

  @override
  void initState() {
    super.initState();
    tween = ColorTween(begin: Colors.black, end: Colors.black);
    updateCharacters();
    widget.tabController.addListener(characterChangedListener);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();
    subscription = widget.broadcaster.listen((event) {
      if (!mounted) return;
      if (event.type == NotificationType.receivedUpdate ||
          event.type == NotificationType.localUpdate) {
        updateCharacters();
      }
    });
  }

  updateCharacters() async {
    var _characters = profile.getCharacters();
    if (_characters == null) return;
    characters = [];
    for (var c in _characters) {
      var equipment = profile.getCharacterEquipment(c.characterId);
      var subclass =
          equipment.firstWhere((i) => i.bucketHash == InventoryBucket.subclass);
      var subclassDef = await manifest
          .getDefinition<DestinyInventoryItemDefinition>(subclass.itemHash);

      characters.add(_CharacterInfo(
          emblemColor: c.emblemColor,
          characterClass: c.classType,
          damageType: subclassDef?.talentGrid?.hudDamageType));
    }
    characterChangedListener();
  }

  @override
  dispose() {
    widget.tabController.removeListener(characterChangedListener);
    subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  characterChangedListener() {
    Color emblemColor;
    var character = widget.tabController.index < characters.length
        ? characters[widget.tabController.index]
        : null;
    if (character != null) {
      emblemColor = Color.fromARGB(255, character.emblemColor.red,
          character.emblemColor.green, character.emblemColor.blue);
    } else {
      emblemColor = Colors.black;
    }

    tween = ColorTween(
        begin: tween.lerp(_controller.value),
        end: Color.lerp(emblemColor, Colors.grey.shade700, .4));
    _controller.reset();
    _controller.forward();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
              decoration: BoxDecoration(
            gradient:
                RadialGradient(center: Alignment.topCenter, radius: 1, colors: [
              tween.evaluate(_controller),
              Color.lerp(tween.evaluate(_controller), Colors.black, .9),
            ]),
          ));
        });
  }
}
