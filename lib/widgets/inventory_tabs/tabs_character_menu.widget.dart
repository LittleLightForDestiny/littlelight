import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:shimmer/shimmer.dart';

class TabsCharacterMenuWidget extends StatelessWidget {
  final List<DestinyCharacterComponent> characters;
  final int selectedIndex;
  TabsCharacterMenuWidget(this.characters, this.selectedIndex);

  @override
  Widget build(BuildContext context) {
    return Positioned(
        right: 8,
        top: getTopPadding(context) + kToolbarHeight - 52,
        width: (characters.length + 1) * 48.0,
        child: TabBar(
          isScrollable: true,
          indicatorColor: Colors.white,
          labelPadding: EdgeInsets.all(0),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: getButtons(),
        ));
  }

  List<Widget> getButtons() {
    if (characters == null) {
      return [Container()];
    }
    List<TabMenuButton> buttons = characters
        .asMap()
        .map((index, character) => MapEntry<int, TabMenuButton>(
            index,
            TabMenuButton(
                character: character, selected: index == selectedIndex)))
        .values
        .toList();

    buttons.add(VaultTabMenuButton(selected:characters.length == selectedIndex));
    return buttons;
  }

  double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}

class TabMenuButton extends StatefulWidget {
  final DestinyCharacterComponent character;
  final bool selected;
  final ManifestService manifest = new ManifestService();

  TabMenuButton({this.character, this.selected});

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
    emblemDefinition =
        await widget.manifest.getItemDefinition(widget.character.emblemHash);
    setState(() {});
  }

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
    Shimmer shimmer = ShimmerHelper.getDefaultShimmer(context);
    if (emblemDefinition == null) {
      return shimmer;
    }
    return CachedNetworkImage(
      imageUrl:
          "${BungieApiService.baseUrl}${emblemDefinition.displayProperties.icon}",
      placeholder: shimmer,
    );
  }
}

class VaultTabMenuButton extends TabMenuButton {
  VaultTabMenuButton({bool selected}) : super(selected: selected);

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
