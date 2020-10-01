import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/corner_badge.decoration.dart';
import 'package:little_light/widgets/common/expiry_date.widget.dart';
import 'package:little_light/widgets/common/item_icon/item_icon.widget.dart';
import 'package:little_light/widgets/common/objective.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class PursuitItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();
  final bool includeCharacterIcon;
  final DestinyItemComponent item;
  final Function onTap;
  final Function onLongPress;
  final bool selectable;

  PursuitItemWidget(
      {Key key,
      this.characterId,
      this.item,
      this.includeCharacterIcon = false,
      this.selectable = false,
      @required this.onTap,
      this.onLongPress})
      : super(key: key);

  PursuitItemWidgetState createState() => PursuitItemWidgetState();
}

class PursuitItemWidgetState<T extends PursuitItemWidget> extends State<T> {
  DestinyInventoryItemDefinition definition;
  Map<int, DestinyObjectiveDefinition> objectiveDefinitions;
  List<DestinyObjectiveProgress> itemObjectives;
  StreamSubscription<NotificationEvent> subscription;
  StreamSubscription<List<ItemWithOwner>> selectionSub;
  bool fullyLoaded = false;

  DestinyItemInstanceComponent instanceInfo;

  String get itemInstanceId => widget.item.itemInstanceId;
  int get hash => widget.item.itemHash;
  DestinyItemComponent get item => widget.item;

  bool get selected =>
      widget.selectable &&
      SelectionService()
          .isSelected(ItemWithOwner(widget.item, widget.characterId));

  @override
  void initState() {
    super.initState();
    updateProgress();
    loadDefinitions();
    subscription = widget.broadcaster.listen((event) {
      if (event.type == NotificationType.receivedUpdate && mounted) {
        updateProgress();
      }
    });
    selectionSub = SelectionService().broadcaster.listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  dispose() {
    subscription.cancel();
    selectionSub.cancel();
    super.dispose();
  }

  Future<void> loadDefinitions() async {
    definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(hash);
    if ((itemObjectives?.length ?? 0) > 0) {
      objectiveDefinitions = await widget.manifest
          .getDefinitions<DestinyObjectiveDefinition>(
              itemObjectives?.map((o) => o.objectiveHash));
    }
    if (mounted) {
      setState(() {});
      fullyLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) {
      return Container(height: 200, color: Colors.blueGrey.shade900);
    }
    return LayoutBuilder(
        builder: (context, constraints) => buildLayout(context, constraints));
  }

  Widget buildLayout(BuildContext context, BoxConstraints constraints) {
    return Stack(children: [
      Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: DestinyData.getTierColor(definition.inventory.tierType),
                width: 1),
            color: Colors.blueGrey.shade900,
          ),
          child: Column(children: <Widget>[
            buildMainInfo(context, constraints),
            buildObjectives(context, definition)
          ])),
      selected
          ? Positioned.fill(
              child: Container(
              foregroundDecoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.lightBlue.shade400, width: 2)),
            ))
          : Container(),
      Positioned.fill(child: buildTapTarget(context))
    ]);
  }

  Widget buildTapTarget(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap();
              return;
            }
            onTap(context);
          },
          onLongPress: () {
            if (widget.onLongPress != null) {
              widget.onLongPress();
              return;
            }
            onLongPress(context);
          },
        ));
  }

  onTap(BuildContext context) {
    if (widget.selectable && UserSettingsService().tapToSelect) {
      if (selected) {
        SelectionService().clear();
      } else {
        SelectionService()
            .setItem(ItemWithOwner(widget.item, widget.characterId));
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetailScreen(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            characterId: widget.characterId,
          ),
        ),
      );
    }
  }

  onLongPress(BuildContext context) {
    if (UserSettingsService().tapToSelect) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ItemDetailScreen(
            item: item,
            definition: definition,
            instanceInfo: instanceInfo,
            characterId: widget.characterId,
          ),
        ),
      );
    }
    if (widget.selectable) {
      if (selected) {
        SelectionService().clear();
      } else {
        SelectionService()
            .setItem(ItemWithOwner(widget.item, widget.characterId));
      }
      return;
    }
  }

  Widget buildCharacterIcon(BuildContext context) {
    if (!widget.includeCharacterIcon || widget.characterId == null) {
      return Container();
    }
    Widget icon;
    var character = widget.profile.getCharacter(widget.characterId);
    icon = QueuedNetworkImage(
        imageUrl: BungieApiService.url(character.emblemPath));

    return Container(
        foregroundDecoration: instanceInfo?.isEquipped == true
            ? BoxDecoration(border: Border.all(width: 2, color: Colors.white))
            : null,
        width: 26,
        height: 26,
        child: icon);
  }

  Widget buildMainInfo(BuildContext context, BoxConstraints constraints) {
    return Expanded(
        flex: constraints.hasBoundedHeight ? 1 : 0,
        child: Stack(children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 80, right: 4),
                color: DestinyData.getTierColor(definition.inventory.tierType),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              definition.displayProperties.name.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ))),
                    buildCharacterIcon(context),
                  ],
                )),
            Expanded(
                flex: constraints.hasBoundedHeight ? 1 : 0,
                child: Container(
                    constraints: BoxConstraints(minHeight: 60),
                    padding: EdgeInsets.all(8).copyWith(left: 88),
                    child: buildDescription(context))),
            item?.expirationDate != null && !isComplete
                ? Container(
                    padding: EdgeInsets.all(8).copyWith(top: 0),
                    child: ExpiryDateWidget(item.expirationDate),
                  )
                : Container(),
          ]),
          Positioned(
              top: 8,
              left: 8,
              width: 72,
              height: 72,
              child: buildIcon(context)),
        ]));
  }

  Widget buildObjectives(
      BuildContext context, DestinyInventoryItemDefinition questStepDef) {
    if (itemObjectives == null) return Container();
    return Container(
      padding: EdgeInsets.all(4).copyWith(top: 0),
      child: Column(
        children: itemObjectives
            .map((objective) => buildObjective(context, objective))
            .toList(),
      ),
    );
  }

  Widget buildObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    var definition = objectiveDefinitions[objective.objectiveHash];
    return Column(
      children: <Widget>[
        ObjectiveWidget(
          definition: definition,
          objective: objective,
        )
      ],
    );
  }

  updateProgress() {
    instanceInfo = widget.profile.getInstanceInfo(itemInstanceId);
    itemObjectives = widget.profile
        .getItemObjectives(itemInstanceId, widget.characterId, hash);
    setState(() {});
  }

  bool get isComplete {
    return itemObjectives?.every((o) => o.complete) ?? false;
  }

  buildIcon(BuildContext context) {
    if (isComplete) {
      return Stack(children: [
        Positioned.fill(child: ItemIconWidget(item, definition, instanceInfo)),
        Positioned.fill(
            child: Container(
          decoration: CornerBadgeDecoration(colors: [
            Color.lerp(Colors.amber.shade400, Colors.grey.shade500, .4)
          ], badgeSize: 28, position: CornerPosition.BottomRight),
        )),
        Positioned(
            right: 2,
            bottom: 4,
            child: Icon(FontAwesomeIcons.exclamation, size: 12))
      ]);
    }
    return ItemIconWidget(item, definition, instanceInfo);
  }

  Widget buildDescription(BuildContext context) {
    return Text(
      definition.displayProperties.description,
      overflow: TextOverflow.fade,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
    );
  }
}
