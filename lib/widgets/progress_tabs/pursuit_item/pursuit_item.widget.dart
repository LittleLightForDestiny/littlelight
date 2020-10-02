import 'dart:async';

import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
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
import 'package:little_light/widgets/common/item_name_bar/item_name_bar.widget.dart';
import 'package:little_light/widgets/common/small_objective.widget.dart';
import 'package:little_light/widgets/item_tags/item_tag.widget.dart';

class PursuitItemWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final NotificationService broadcaster = NotificationService();
  final Widget trailing;
  final DestinyItemComponent item;
  final Function onTap;
  final Function onLongPress;
  final bool selectable;
  final double tagIconSize;
  final double iconSize;
  final double titleFontSize;
  final double paddingSize;

  PursuitItemWidget(
      {Key key,
      this.characterId,
      this.item,
      this.trailing,
      this.selectable = false,
      this.tagIconSize = 10,
      this.titleFontSize = 12,
      this.iconSize = 56,
      this.paddingSize = 4,
      this.onTap,
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
          onTap: widget.selectable
              ? () {
                  if (widget.onTap != null) {
                    widget.onTap();
                    return;
                  }
                  onTap(context);
                }
              : null,
          onLongPress: widget.selectable
              ? () {
                  if (widget.onLongPress != null) {
                    widget.onLongPress();
                    return;
                  }
                  onLongPress(context);
                }
              : null,
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

  Widget namebarTrailingWidget(BuildContext context) {
    List<Widget> items = [];

    var notes = ItemNotesService()
        .getNotesForItem(item?.itemHash, item?.itemInstanceId);
    var tags = ItemNotesService().tagsByIds(notes?.tags);
    if (tags != null) {
      items.addAll(tags.map((t) => ItemTagWidget(
            t,
            fontSize: widget.tagIconSize,
            // padding: padding / 8,
          )));
    }
    if (widget.trailing != null) {
      items.add(widget.trailing);
    }
    if ((items?.length ?? 0) == 0) return Container();
    items = items
        .expand((i) => [
              i,
              Container(
                width: 2,
              )
            ])
        .toList();
    items.removeLast();
    return Row(
      children: items,
    );
  }

  Widget buildMainInfo(BuildContext context, BoxConstraints constraints) {
    return Expanded(
        flex: constraints.hasBoundedHeight ? 1 : 0,
        child: Stack(children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ItemNameBarWidget(
              item,
              definition,
              instanceInfo,
              characterId: widget.characterId,
              fontSize: widget.titleFontSize,
              multiline: false,
              padding: EdgeInsets.all(widget.paddingSize)
                  .copyWith(left: widget.iconSize + widget.paddingSize * 2),
              trailing: namebarTrailingWidget(context),
            ),
            Container(
              padding: EdgeInsets.all(widget.paddingSize / 2)
                  .copyWith(left: widget.iconSize + widget.paddingSize * 3),
              child: item?.expirationDate != null && !isComplete
                  ? ExpiryDateWidget(
                      item.expirationDate,
                      fontSize: widget.titleFontSize,
                    )
                  : Container(),
            ),
            Expanded(
                flex: constraints.hasBoundedHeight ? 1 : 0,
                child: Container(
                    padding: EdgeInsets.all(widget.paddingSize / 2).copyWith(
                        left: widget.iconSize + widget.paddingSize * 3),
                    child: buildDescription(context))),
          ]),
          Positioned(
              top: widget.paddingSize,
              left: widget.paddingSize,
              width: widget.iconSize,
              height: widget.iconSize,
              child: buildIcon(context)),
        ]));
  }

  Widget buildObjectives(
      BuildContext context, DestinyInventoryItemDefinition questStepDef) {
    if (itemObjectives == null) return Container();
    return Container(
      padding: EdgeInsets.all(4).copyWith(top: 0),
      child: Row(
        children: itemObjectives
            .map((objective) => Expanded(
                child: Container(
                    margin: EdgeInsets.all(2),
                    child: buildObjective(context, objective))))
            .toList(),
      ),
    );
  }

  Widget buildObjective(
      BuildContext context, DestinyObjectiveProgress objective) {
    if (objectiveDefinitions == null) return Container();
    if (isComplete) return Container();
    var definition = objectiveDefinitions[objective.objectiveHash];
    return SmallObjectiveWidget(
      definition: definition,
      objective: objective,
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
