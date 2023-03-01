// @dart=2.9

import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/widgets/loading/default_loading_shimmer.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class TabsCharacterMenuWidget extends StatelessWidget {
  final List<DestinyCharacterInfo> characters;
  final TabController controller;
  final bool includeVault;

  const TabsCharacterMenuWidget(this.characters,
      {this.controller, this.includeVault = true});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: TabBar(
      controller: controller,
      isScrollable: true,
      indicatorColor: Theme.of(context).colorScheme.onSurface,
      labelPadding: const EdgeInsets.all(0),
      indicatorSize: TabBarIndicatorSize.label,
      tabs: getButtons(),
    ));
  }

  List<Widget> getButtons() {
    if ((characters?.length ?? 0) == 0) {
      return [Container()];
    }
    String lastPlayedCharId = characters.first.characterId;
    DateTime lastPlayedDate =
        DateTime.tryParse(characters.first.character.dateLastPlayed) ??
            DateTime.fromMicrosecondsSinceEpoch(0);
    for (var char in characters) {
      var date = DateTime.tryParse(char.character.dateLastPlayed) ??
          DateTime.fromMicrosecondsSinceEpoch(0);
      if (date.isAfter(lastPlayedDate)) {
        lastPlayedDate = date;
        lastPlayedCharId = char.characterId;
      }
    }
    List<TabMenuButton> buttons = characters
        .asMap()
        .map((index, character) => MapEntry<int, TabMenuButton>(
            index,
            TabMenuButton(
                key: Key(
                    "tabmenu_${character.characterId}_${character.character.emblemHash}"),
                lastPlayed: character.characterId == lastPlayedCharId,
                character: character.character)))
        .values
        .toList();
    if (includeVault) {
      buttons.add(VaultTabMenuButton());
    }
    return buttons;
  }

  double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}

class TabMenuButton extends StatefulWidget {
  final DestinyCharacterComponent character;

  final bool lastPlayed;

  const TabMenuButton({this.character, Key key, this.lastPlayed = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => TabMenuButtonState();
}

class TabMenuButtonState extends State<TabMenuButton> with ManifestConsumer {
  DestinyInventoryItemDefinition emblemDefinition;

  @override
  void initState() {
    super.initState();
    getDefinitions();
  }

  getDefinitions() async {
    emblemDefinition =
        await manifest.getDefinition<DestinyInventoryItemDefinition>(
            widget.character.emblemHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.onSurface, width: 1)),
        foregroundDecoration: widget.lastPlayed
            ? const CornerBadgeDecoration(
                badgeSize: 15,
                position: CornerPosition.TopLeft,
                colors: [Colors.yellow])
            : null,
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
        child: getImage(context));
  }

  Widget getImage(context) {
    if (emblemDefinition == null) {
      return const DefaultLoadingShimmer();
    }
    return QueuedNetworkImage(
      key: Key("emblem_${emblemDefinition.hash}"),
      imageUrl: BungieApiService.url(emblemDefinition.displayProperties.icon),
      placeholder: const DefaultLoadingShimmer(),
    );
  }
}

class VaultTabMenuButton extends TabMenuButton {
  @override
  State<StatefulWidget> createState() => VaultTabMenuButtonState();
}

class VaultTabMenuButtonState extends TabMenuButtonState {
  @override
  getDefinitions() {}

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.onSurface, width: 1)),
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
        child: getImage(context));
  }

  @override
  Widget getImage(context) {
    return Image.asset("assets/imgs/vault-icon.jpg");
  }
}
