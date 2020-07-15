import 'dart:async';

import 'package:bungie_api/models/destiny_faction_definition.dart';
import 'package:bungie_api/models/destiny_faction_progression.dart';
import 'package:bungie_api/models/destiny_progression_definition.dart';
import 'package:bungie_api/models/destiny_progression_step_definition.dart';
import 'package:bungie_api/models/destiny_vendor_definition.dart';

import 'package:flutter/material.dart';

import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/filled_diamond_progress_indicator.dart';

class FactionRankItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();

  final DestinyFactionProgression progression;

  FactionRankItemWidget({Key key, this.characterId, this.progression})
      : super(key: key);

  FactionRankItemWidgetState createState() => FactionRankItemWidgetState();
}

class FactionRankItemWidgetState<T extends FactionRankItemWidget>
    extends State<T> with AutomaticKeepAliveClientMixin {
  DestinyProgressionDefinition definition;
  DestinyFactionDefinition factionDefinition;
  DestinyVendorDefinition vendorDefinition;
  StreamSubscription<NotificationEvent> subscription;
  int get hash => widget.progression.factionHash;
  DestinyFactionProgression progression;

  @override
  void initState() {
    super.initState();
    
    progression = widget.progression;
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {
        progression = widget.profile
            .getCharacterProgression(widget.characterId)
            .factions["$hash"];
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    definition = await widget.manifest
        .getDefinition<DestinyProgressionDefinition>(
            widget.progression.progressionHash);
    factionDefinition = await widget.manifest
        .getDefinition<DestinyFactionDefinition>(progression.factionHash);
    if ((factionDefinition?.vendors?.length ?? 0) > 0) {
      vendorDefinition = await widget.manifest
          .getDefinition<DestinyVendorDefinition>(factionDefinition
              .vendors[factionDefinition.vendors.length - 1].vendorHash);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (definition == null ||
        progression == null ||
        factionDefinition == null) {
      return Container(height: 200, color: Colors.blueGrey.shade900);
    }
    return Container(
        padding: EdgeInsets.all(2),
        child: Stack(children: [
          buildBackground(context),
          buildContent(context),
          buildStepProgress(context),
        ]));
  }

  Widget buildBackground(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: .5, child: Container()),
          Expanded(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                alignment: Alignment.centerRight,
                decoration: BoxDecoration(
                    color: Colors.black,
                    border:
                        Border.all(color: Colors.blueGrey.shade300, width: 1)),
                child: Stack(fit: StackFit.passthrough, children: [
                  QueuedNetworkImage(
                    fit: BoxFit.fitHeight,
                    imageUrl: BungieApiService.url(
                        vendorDefinition?.displayProperties?.largeIcon),
                  ),
                  Positioned.fill(
                      child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: <Color>[Colors.black, Colors.black38],
                            begin: Alignment.centerLeft,
                            end: Alignment.center)),
                  )),
                ])),
          )
        ]);
  }

  Widget buildContent(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 1, child: Container()),
          Expanded(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text(
                          vendorDefinition?.displayProperties?.name ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        TranslatedTextWidget(
                          "Level {Level}",
                          replace: {"Level":"${progression.level}"},
                          key:Key("${progression.level}"),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        )
                      ]),
                    ),
                    Container(
                      height: 2,
                    ),
                    Text(
                      factionDefinition?.displayProperties?.name ?? vendorDefinition?.displayProperties?.name ?? "",
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Text(
                        "${progression?.progressToNextLevel}/${progression?.nextLevelAt}")
                  ],
                )),
          )
        ]);
  }

  buildStepProgress(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1,
        child: Stack(children: [
          Positioned.fill(
              child: FilledDiamondProgressIndicator(
                  backgroundColor: Colors.blueGrey.shade500,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.blueGrey.shade100),
                  value: progression.progressToNextLevel /
                      progression.nextLevelAt)),
          Positioned.fill(
              child: Container(
                  padding: EdgeInsets.all(4),
                  child: QueuedNetworkImage(
                    imageUrl: BungieApiService.url(
                        factionDefinition?.displayProperties?.icon),
                  )))
        ]));
  }

  DestinyProgressionStepDefinition get currentStep =>
      definition.steps[widget.progression.level];

  @override
  bool get wantKeepAlive => true;
}
