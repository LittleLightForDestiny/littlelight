//@dart=2.12

import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/enums/destiny_component_type.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_class_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_race_definition.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/icon_fonts/littlelight_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SupporterCharacterWidget extends StatefulWidget {
  final String membershipId;
  final BungieMembershipType membershipType;
  final String? link;
  final Widget? badge;
  SupporterCharacterWidget(this.membershipId, this.membershipType, [this.link, this.badge]);

  @override
  State<StatefulWidget> createState() {
    return SupporterCharacterWidgetState();
  }
}

class SupporterCharacterWidgetState extends State<SupporterCharacterWidget>
    with AutomaticKeepAliveClientMixin, BungieApiConsumer {
  DestinyCharacterComponent? lastPlayed;
  UserInfoCard? userInfo;

  @override
  void initState() {
    super.initState();
    loadCharacters();
  }

  loadCharacters() async {
    var profile = await bungieAPI.getProfile([DestinyComponentType.Characters, DestinyComponentType.Profiles],
        "${widget.membershipId}", widget.membershipType);
    List<DestinyCharacterComponent>? list = profile?.characters?.data?.values.toList();
    if(list == null || list.length == 0) return;
    list.sort((charA, charB) {
      DateTime dateA = DateTime.tryParse(charA.dateLastPlayed ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
      DateTime dateB = DateTime.tryParse(charB.dateLastPlayed ?? "") ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });
    lastPlayed = list.first;
    userInfo = profile?.profile?.data?.userInfo;
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        height: 72,
        child: Stack(children: [
          Positioned.fill(child: buildEmblemBackground(context)),
          Positioned(left: 8, top: 8, bottom: 8, child: buildEmblemIcon(context)),
          Positioned(
              left: 82,
              top: 4,
              bottom: 4,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildPlayerName(context),
                    buildPlayerClass(context),
                    widget.badge ?? Container()
                  ])),
          Positioned(
            bottom: 8,
            right: 8,
            child: buildPlatformIcon(context),
          ),
          Positioned(
            top: 4,
            right: 8,
            child: buildPlayerLevel(context),
          ),
          Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      launch(widget.link ??
                          "https://www.bungie.net/en/Profile/${widget.membershipType.value}/${widget.membershipId}");
                    },
                  )))
        ]));
  }

  Widget buildEmblemBackground(BuildContext context) {
    final emblemHash = this.lastPlayed?.emblemHash;
    if (emblemHash == null) return Container();
    return ManifestImageWidget<DestinyInventoryItemDefinition>(
      emblemHash,
      fit: BoxFit.cover,
      alignment: Alignment.centerLeft,
      urlExtractor: (def) {
        return def.secondarySpecial;
      },
    );
  }

  Widget buildEmblemIcon(BuildContext context) {
    final emblemHash = this.lastPlayed?.emblemHash;
    if (emblemHash == null) return Container();
    return Container(
      width: 64,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(
      emblemHash,
      urlExtractor: (def) {
        return def.secondaryOverlay;
      },
    ));
  }

  Widget buildPlayerName(BuildContext context) {
    final userInfo = this.userInfo;
    if (userInfo == null) return Container();
    return Text(
      "${userInfo.displayName}",
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget buildPlayerLevel(BuildContext context) {
    final lightLevel = lastPlayed?.light;
    if (lightLevel == null) return Text(" ");
    return Row(
      children: <Widget>[
        Icon(
          LittleLightIcons.power,
          size: 12,
          color: Colors.amber.shade200,
        ),
        Text("$lightLevel",
            style: TextStyle(color: Colors.amber.shade200, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildPlatformIcon(BuildContext context) {
    var plat = PlatformData.getPlatform(widget.membershipType);
    return Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(color: plat.color, borderRadius: BorderRadius.circular(20)),
        child: Icon(
          plat.icon,
          size: 20,
        ));
  }

  Widget buildPlayerClass(BuildContext context) {
    final genderHash = lastPlayed?.genderHash;
    final classHash = lastPlayed?.classHash;
    final raceHash = lastPlayed?.raceHash;
    return Row(children: [
      classHash != null ? ManifestText<DestinyClassDefinition>(classHash, textExtractor: (def) {
        return def.genderedClassNamesByGenderHash?["$genderHash"] ?? def.displayProperties?.name;
      }, style: TextStyle(fontSize: 12)) : Container(),
      Text(" - ", style: TextStyle(fontSize: 12)),
      raceHash != null ? ManifestText<DestinyRaceDefinition>(raceHash, textExtractor: (def) {
        return def.genderedRaceNamesByGenderHash?["$genderHash"] ?? def.displayProperties?.name;
      }, style: TextStyle(fontSize: 12)) : Container(),
    ]);
  }

  @override
  bool get wantKeepAlive => true;
}
