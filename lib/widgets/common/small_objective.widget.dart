// @dart=2.9

import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';

class SmallObjectiveWidget extends StatelessWidget {
  const SmallObjectiveWidget(
      {Key key,
      DestinyObjectiveDefinition definition,
      Color color,
      bool forceComplete = false,
      DestinyObjectiveProgress objective,
      String placeholder,
      bool parentCompleted = false})
      : super();

  @override
  Widget build(BuildContext context) {
    return Container();
  }
  // : super(0,
  //       key: key,
  //       color: color,
  //       forceComplete: forceComplete,
  //       objective: objective,∏
  //       placeholder: placeholder,
  //       parentCompleted: parentCompleted);
}

// class SmallObjectiveWidgetState extends ObjectiveWidgetState {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         children: [buildProgressValue(context), buildProgressBar(context), Container(height: 2), buildTitle(context)]);
//   }

//   @override
//   bool get isComplete {
//     return (objective?.complete == true || forceComplete) ?? false;
//   }

//   @override
//   buildProgressValue(BuildContext context) {
//     int progress = objective?.progress ?? 0;
//     int total = definition.completionValue ?? 0;
//     if (total <= 1) {
//       return Text(
//         "",
//         style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: color ?? Colors.grey.shade300),
//       );
//     }
//     if (!definition.allowOvercompletion) {
//       progress = min(total, progress);
//     }

//     if (forceComplete) {
//       progress = total;
//     }
//     var percent = (progress / total * 100).round();
//     return Text("$percent%",
//         softWrap: false,
//         overflow: TextOverflow.clip,
//         style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: color ?? Colors.grey.shade300));
//   }

//   @override
//   buildProgressBar(BuildContext context) {
//     int progress = objective?.progress ?? 0;
//     int total = definition.completionValue ?? 0;
//     return Container(
//         height: 4,
//         color: Theme.of(context).colorScheme.secondary,
//         alignment: Alignment.centerLeft,
//         child: progress <= 0
//             ? Container()
//             : FractionallySizedBox(
//                 widthFactor: max(0.01, min(progress / total, 1)),
//                 child: Container(color: barColor),
//               ));
//   }

//   @override
//   buildTitle(BuildContext context) {
//     String title = definition?.progressDescription ?? "";
//     if (title.isEmpty) {
//       title = placeholder ?? "";
//     }

//     return Container(
//         child: Text(title.toUpperCase(),
//             maxLines: 1,
//             softWrap: false,
//             overflow: TextOverflow.fade,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: color ?? Colors.grey.shade300)));
//   }

//   @override
//   Color get barColor {
//     if (parentCompleted == true) {
//       return color;
//     }
//     return DestinyData.objectiveProgress;
//   }
// }
