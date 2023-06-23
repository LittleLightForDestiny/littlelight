// // @dart=2.9

// import 'dart:async';

// import 'package:bungie_api/models/destiny_faction_definition.dart';
// import 'package:bungie_api/models/destiny_faction_progression.dart';
// import 'package:bungie_api/models/destiny_progression_definition.dart';
// import 'package:bungie_api/models/destiny_progression_step_definition.dart';
// import 'package:bungie_api/models/destiny_vendor_definition.dart';
// import 'package:flutter/material.dart';
// import 'package:little_light/core/blocs/profile/profile.consumer.dart';
// import 'package:little_light/core/theme/littlelight.theme.dart';
// import 'package:little_light/services/bungie_api/bungie_api.service.dart';
// import 'package:little_light/services/manifest/manifest.consumer.dart';
// import 'package:little_light/widgets/common/queued_network_image.widget.dart';
// import 'package:little_light/widgets/common/translated_text.widget.dart';
// import 'package:little_light/widgets/flutter/filled_diamond_progress_indicator.dart';

// class FactionRankItemWidget extends StatefulWidget {
//   final String characterId;

//   final DestinyFactionProgression progression;

//   const FactionRankItemWidget({Key key, this.characterId, this.progression}) : super(key: key);

//   @override
//   FactionRankItemWidgetState createState() => FactionRankItemWidgetState();
// }

// class FactionRankItemWidgetState<T extends FactionRankItemWidget> extends State<T>
//     with AutomaticKeepAliveClientMixin, ProfileConsumer, ManifestConsumer {
//   DestinyProgressionDefinition definition;
//   DestinyFactionDefinition factionDefinition;
//   DestinyVendorDefinition vendorDefinition;
//   int get presentationNodeHash => widget.progression.factionHash;
//   DestinyFactionProgression progression;

//   @override
//   void initState() {
//     super.initState();

//     progression = widget.progression;
//     loadDefinitions();
//     profile.addListener(update);
//   }

//   update() {
//     if (!mounted) return;
//     progression = profile.getCharacterProgression(widget.characterId).factions["$presentationNodeHash"];
//     setState(() {});
//   }

//   @override
//   dispose() {
//     profile.removeListener(update);
//     super.dispose();
//   }

//   Future<void> loadDefinitions() async {
//     definition = await manifest.getDefinition<DestinyProgressionDefinition>(widget.progression.progressionHash);
//     factionDefinition = await manifest.getDefinition<DestinyFactionDefinition>(progression.factionHash);
//     if ((factionDefinition?.vendors?.length ?? 0) > 0) {
//       vendorDefinition = await manifest.getDefinition<DestinyVendorDefinition>(
//           factionDefinition.vendors[factionDefinition.vendors.length - 1].vendorHash);
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     if (definition == null || progression == null || factionDefinition == null) {
//       return Container(height: 200, color: Theme.of(context).colorScheme.secondaryContainer);
//     }
//     return Container(
//         padding: const EdgeInsets.all(2),
//         child: Stack(children: [
//           buildBackground(context),
//           buildContent(context),
//           buildStepProgress(context),
//         ]));
//   }

//   Widget buildBackground(BuildContext context) {
//     return Row(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start, children: [
//       AspectRatio(aspectRatio: .5, child: Container()),
//       Expanded(
//           child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         alignment: Alignment.centerRight,
//         decoration: BoxDecoration(
//             color: LittleLightTheme.of(context).surfaceLayers.layer0,
//             border: Border.all(color: LittleLightTheme.of(context).surfaceLayers.layer3, width: 1)),
//       ))
//     ]);
//   }

//   Widget buildContent(BuildContext context) {
//     return Row(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisAlignment: MainAxisAlignment.start, children: [
//       AspectRatio(aspectRatio: 1, child: Container()),
//       Expanded(
//         child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//             padding: const EdgeInsets.all(4),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 Container(
//                   child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                     Text(
//                       vendorDefinition?.displayProperties?.name ?? "",
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                     ),
//                     TranslatedTextWidget(
//                       "Level {Level}",
//                       replace: {"Level": "${progression.level}"},
//                       key: Key("${progression.level}"),
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                     )
//                   ]),
//                 ),
//                 Container(
//                   height: 2,
//                 ),
//                 Text(
//                   factionDefinition?.displayProperties?.name ?? vendorDefinition?.displayProperties?.name ?? "",
//                   style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
//                 ),
//                 Expanded(
//                   child: Container(),
//                 ),
//                 Text("${progression?.progressToNextLevel}/${progression?.nextLevelAt}")
//               ],
//             )),
//       )
//     ]);
//   }

//   buildStepProgress(BuildContext context) {
//     return AspectRatio(
//         aspectRatio: 1,
//         child: Stack(children: [
//           Positioned.fill(
//               child: FilledDiamondProgressIndicator(
//                   backgroundColor: Theme.of(context).colorScheme.secondary,
//                   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
//                   value: progression.progressToNextLevel / progression.nextLevelAt)),
//           Positioned.fill(
//               child: Container(
//                   padding: const EdgeInsets.all(4),
//                   child: QueuedNetworkImage(
//                     imageUrl: BungieApiService.url(factionDefinition?.displayProperties?.icon),
//                   )))
//         ]));
//   }

//   DestinyProgressionStepDefinition get currentStep => definition.steps[widget.progression.level];

//   @override
//   bool get wantKeepAlive => true;
// }
