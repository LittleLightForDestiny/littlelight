import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:bungie_api/models/destiny_character_progression_component.dart';
import 'package:bungie_api/models/destiny_progression.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:little_light/services/bungie-api/bungie-api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:shimmer/shimmer.dart';

class TabHeaderWidget extends StatefulWidget {
  final String characterId;
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  @override
  TabHeaderWidget(this.characterId);

  @override
  TabHeaderWidgetState createState() => new TabHeaderWidgetState();
}

class TabHeaderWidgetState extends State<TabHeaderWidget> {
  DestinyInventoryItemDefinition emblemDefinition;
  DestinyCharacterComponent character;
  DestinyCharacterProgressionComponent progression;
  @override
  void initState() {
    character = widget.profile.getCharacter(widget.characterId);
    progression = widget.profile.getCharacterProgression(widget.characterId);
    emblemDefinition =
        widget.manifest.getItemDefinition(character.emblemHash);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[emblemBackground(context), powerBar(context)],
        ),
        emblemIcon(context)
      ],
    );
  }

  Widget emblemIcon(BuildContext context) {
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Colors.transparent,
        highlightColor: Colors.white,
        child: Icon(
          DestinyData.getClassIcon(character.classType),
          size: 56,
        ));
    double top = getTopPadding(context) + 10;
    return Positioned(
        left: 40,
        top: top,
        width: 56,
        height: 56,
        child: CachedNetworkImage(
          imageUrl:
              "${BungieApiService.baseUrl}${emblemDefinition.secondaryOverlay}",
          fit: BoxFit.fill,
          placeholder: shimmer,
        ));
  }

  Widget emblemBackground(BuildContext context) {
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .1),
        highlightColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .3),
        child: Container(color: Colors.white));
    double height = getTopPadding(context) + kToolbarHeight;
    return Container(
        height: height,
        color: Theme.of(context).backgroundColor,
        child: CachedNetworkImage(
          imageUrl:
              "${BungieApiService.baseUrl}${emblemDefinition.secondarySpecial}",
          placeholder: shimmer,
          fit: BoxFit.cover,
          alignment: AlignmentDirectional.center,
        ));
  }

  Widget powerBar(BuildContext context) {
    DestinyProgression levelProg = character.levelProgression;
    bool isMaxLevel = levelProg.level >= levelProg.levelCap;
    MaterialColor fg = isMaxLevel ? Colors.amber : Colors.green;
    Color bg = Color.lerp(Colors.black, fg, .6);
    Color shine = fg.shade200;

    if (isMaxLevel) {
      levelProg = progression.progressions[ProgressionHash.Overlevel];
    }
    double completed = levelProg.progressToNextLevel / levelProg.nextLevelAt;
    return Container(
      height: 2,
      color: bg,
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: completed,
        child: Shimmer.fromColors(
            baseColor: fg,
            period: Duration(seconds: 2),
            highlightColor: shine,
            child: Container(
              color: Colors.white,
            )),
      ),
    );
  }

  double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
