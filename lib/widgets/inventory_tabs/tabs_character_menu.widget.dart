import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:shimmer/shimmer.dart';

class TabsCharacterMenuWidget extends StatelessWidget {
  final List<DestinyCharacterComponent> characters;
  final TabController controller;
  final bool includeVault;

  TabsCharacterMenuWidget(this.characters,
      {this.controller, this.includeVault = true});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: TabBar(
      controller: controller,
      isScrollable: true,
      indicatorColor: Colors.white,
      labelPadding: EdgeInsets.all(0),
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
        DateTime.tryParse(characters.first.dateLastPlayed) ??
            DateTime.fromMicrosecondsSinceEpoch(0);
    characters.forEach((char) {
      var date = DateTime.tryParse(char.dateLastPlayed) ??
          DateTime.fromMicrosecondsSinceEpoch(0);
      if (date.isAfter(lastPlayedDate)) {
        lastPlayedDate = date;
        lastPlayedCharId = char.characterId;
      }
    });
    List<TabMenuButton> buttons = characters
        .asMap()
        .map((index, character) => MapEntry<int, TabMenuButton>(
            index,
            TabMenuButton(
                key: Key(
                    "tabmenu_${character.characterId}_${character.emblemHash}"),
                lastPlayed: character.characterId == lastPlayedCharId,
                character: character)))
        .values
        .toList();
    if (this.includeVault) {
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
  final ManifestService manifest = new ManifestService();
  final bool lastPlayed;

  TabMenuButton({this.character, Key key, this.lastPlayed = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new TabMenuButtonState();
}

class TabMenuButtonState extends State<TabMenuButton> {
  DestinyInventoryItemDefinition emblemDefinition;

  @override
  void initState() {
    super.initState();
    getDefinitions();
  }

  getDefinitions() async {
    emblemDefinition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(
            widget.character.emblemHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
        foregroundDecoration: widget.lastPlayed
            ? CornerBadgeDecoration(
                badgeSize: 15,
                position: CornerPosition.TopLeft,
                colors: [Colors.yellow])
            : null,
        width: 40,
        height: 40,
        margin: EdgeInsets.only(left: 4, right: 4, bottom: 10),
        child: getImage(context));
  }

  Widget getImage(context) {
    Shimmer shimmer = ShimmerHelper.getDefaultShimmer(context);
    if (emblemDefinition == null) {
      return shimmer;
    }
    return QueuedNetworkImage(
      key: Key("emblem_${emblemDefinition.hash}"),
      imageUrl: BungieApiService.url(emblemDefinition.displayProperties.icon),
      placeholder: shimmer,
    );
  }
}

class VaultTabMenuButton extends TabMenuButton {
  @override
  State<StatefulWidget> createState() => new VaultTabMenuButtonState();
}

class VaultTabMenuButtonState extends TabMenuButtonState {
  @override
  void initState() {
    super.initState();
  }

  @override
  getDefinitions() {}

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
        width: 40,
        height: 40,
        margin: EdgeInsets.only(left: 4, right: 4, bottom: 10),
        child: getImage(context));
  }

  Widget getImage(context) {
    return Image.asset("assets/imgs/vault-icon.jpg");
  }
}
