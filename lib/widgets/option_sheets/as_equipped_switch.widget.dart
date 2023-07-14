// // @dart=2.9

// import 'package:flutter/material.dart';
// import 'package:little_light/core/blocs/language/language.consumer.dart';

// typedef AsEquippedChanged = void Function(bool equipped);

// class AsEquippedSwitchWidget extends StatefulWidget {
//   final AsEquippedChanged onChanged;

//   const AsEquippedSwitchWidget({Key key, this.onChanged}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() {
//     return AsEquippedSwitchWidgetState();
//   }
// }

// class AsEquippedSwitchWidgetState extends State<AsEquippedSwitchWidget> {
//   bool asEquipped = false;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         child: Row(
//           children: <Widget>[
//             Expanded(child: Text("As Equipped".translate(context))),
//             Switch(
//               value: asEquipped,
//               onChanged: (bool value) {
//                 asEquipped = value;
//                 setState(() {});
//                 if (widget.onChanged != null) {
//                   widget.onChanged(asEquipped);
//                 }
//               },
//             ),
//           ],
//         ));
//   }
// }
