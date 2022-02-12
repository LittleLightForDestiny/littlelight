// @dart=2.9

import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';

import 'large_pursuit_item.widget.dart';

class TrackedPursuitItemWidget extends LargePursuitItemWidget {
  TrackedPursuitItemWidget(
      {Key key, String characterId, DestinyItemComponent item, Function onTap, Function onLongPress})
      : super(
            key: key,
            characterId: characterId,
            item: item,
            // includeCharacterIcon: true,
            onTap: onTap);

  TrackedPursuitItemWidgetState createState() => TrackedPursuitItemWidgetState();
}

class TrackedPursuitItemWidgetState<T extends TrackedPursuitItemWidget> extends LargePursuitItemWidgetState<T> {
  DestinyItemComponent _item;

  @override
  DestinyItemComponent get item {
    return _item ?? super.item;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  Widget buildObjective(BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    return super.buildObjective(context, objective);
  }
}
