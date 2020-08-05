import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';

import 'package:flutter/material.dart';

import 'package:little_light/widgets/progress_tabs/pursuit_item.widget.dart';

class TrackedPursuitItemWidget extends PursuitItemWidget {
  TrackedPursuitItemWidget(
      {Key key,
      String characterId,
      DestinyItemComponent item,
      OnPursuitTap onTap})
      : super(
            key: key,
            characterId: characterId,
            item: item,
            includeCharacterIcon: true,
            onTap: onTap);

  TrackedPursuitItemWidgetState createState() =>
      TrackedPursuitItemWidgetState();
}

class TrackedPursuitItemWidgetState<T extends TrackedPursuitItemWidget>
    extends PursuitItemWidgetState<T> {
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

  Widget buildObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    return super.buildObjective(context, objective);
  }

  @override
  bool get wantKeepAlive => itemObjectives != null;
}
