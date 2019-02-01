import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:flutter/material.dart';

class ObjectiveWidget extends StatelessWidget {
  final DestinyObjectiveDefinition definition;
  final Color color;

  const ObjectiveWidget({Key key, this.definition, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        child: Row(children: [
          buildCheck(context),
          Expanded(
            child: buildBar(context),
          )
        ]));
  }

  Widget buildCheck(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: this.color ?? Colors.grey.shade300)),
        width: 18,
        height: 18);
  }

  buildBar(BuildContext context) {
    if (definition == null) return Container();
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Text(definition.progressDescription,
            style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13)));
  }
}
