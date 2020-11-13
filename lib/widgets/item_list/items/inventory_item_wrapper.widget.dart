import 'dart:async';
import 'dart:math';

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/screens/quick_transfer.screen.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/selection/selection.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/item_with_owner.dart';

import 'package:little_light/widgets/item_list/items/armor/armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/medium_armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/armor/minimal_armor_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/medium_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/base/minimal_base_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/emblem/emblem_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/emblem/medium_emblem_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/engram/empty_engram_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/engram/minimal_engram_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/loading_inventory_item_widget.dart';
import 'package:little_light/widgets/item_list/items/quick_transfer_destination_inventory_item_widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/medium_subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/subclass/subclass_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/medium_weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/minimal_weapon_inventory_item.widget.dart';
import 'package:little_light/widgets/item_list/items/weapon/weapon_inventory_item.widget.dart';
import 'package:uuid/uuid.dart';

enum ContentDensity { MINIMAL, MEDIUM, FULL }

class InventoryItemWrapperWidget extends StatefulWidget {
  final ManifestService manifest = ManifestService();
  final ProfileService profile = ProfileService();
  final DestinyItemComponent item;
  final String characterId;
  final ContentDensity density;
  final int bucketHash;
  InventoryItemWrapperWidget(this.item, this.bucketHash,
      {Key key, @required this.characterId, this.density = ContentDensity.FULL})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InventoryItemWrapperWidgetState();
  }
}

class InventoryItemWrapperWidgetState<T extends InventoryItemWrapperWidget>
    extends State<T> {
  DestinyInventoryItemDefinition definition;
  String uniqueId;
  bool selected = false;

  StreamSubscription<List<ItemWithOwner>> selectionSubscription;
  StreamSubscription<NotificationEvent> stateSubscription;

  DestinyItemInstanceComponent get instanceInfo {
    return widget.profile.getInstanceInfo(widget.item.itemInstanceId);
  }

  static int queueSize = 0;

  @override
  void initState() {
    uniqueId = Uuid().v4();
    this.definition = widget.manifest
        .getDefinitionFromCache<DestinyInventoryItemDefinition>(
            widget?.item?.itemHash);

    super.initState();
    if (widget.item != null && this.definition == null) {
      getDefinitions();
    }

    selected = SelectionService()
        .isSelected(ItemWithOwner(widget.item, widget.characterId));

    selectionSubscription = SelectionService().broadcaster.listen((event) {
      if (!mounted) return;
      var isSelected = SelectionService()
          .isSelected(ItemWithOwner(widget.item, widget.characterId));
      if (isSelected != selected) {
        selected = isSelected;
        setState(() {});
      }
    });
    stateSubscription = NotificationService().listen((event) {
      if (!mounted) return;
      if (event.type == NotificationType.itemStateUpdate &&
          event.item.itemHash == widget.item?.itemHash &&
          event.item.itemInstanceId == widget.item?.itemInstanceId) {
        setState(() {});
      }
    });
  }

  @override
  dispose() {
    selectionSubscription.cancel();
    stateSubscription.cancel();
    super.dispose();
  }

  bool get isLoaded {
    if (widget.item == null) {
      return false;
    }
    return widget.manifest
        .isLoaded<DestinyInventoryItemDefinition>(widget.item.itemHash);
  }

  bool get quickTransferAvailable {
    return widget.characterId != null &&
        ![
          InventoryBucket.subclass,
          InventoryBucket.lostItems,
          InventoryBucket.engrams,
          InventoryBucket.emblems,
        ].contains(widget.bucketHash);
  }

  getDefinitions() async {
    queueSize++;
    if (queueSize > 1) {
      await Future.delayed(Duration(milliseconds: 100 * min(queueSize, 20)));
      if (!mounted) {
        queueSize--;
        return;
      }
    }
    definition = await widget.manifest
        .getDefinition<DestinyInventoryItemDefinition>(widget.item.itemHash);
    if (mounted) {
      setState(() {});
    }
    queueSize--;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(child: buildCrossfade(context)),
      selected
          ? Container(
              foregroundDecoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.lightBlue.shade400, width: 2)),
            )
          : Container(),
      buildTapHandler(context)
    ]);
  }

  Widget buildCrossfade(BuildContext context) {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 500),
      firstChild: buildEmpty(context),
      secondChild: buildItem(context),
      crossFadeState: definition == null
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }

  Widget buildTapHandler(BuildContext context) {
    if (widget.item == null && quickTransferAvailable) {
      return Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                enableFeedback: false,
                onTap: () {
                  onEmptyTap(context);
                },
              )));
    }
    if (widget.item != null) {
      return Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                enableFeedback: false,
                onTap: () {
                  onTap(context);
                },
                onLongPress: () {
                  onLongPress(context);
                },
                onDoubleTap: () {
                  onDoubleTap(context);
                },
              )));
    }
    return Container();
  }

  void onEmptyTap(BuildContext context) async {
    var bucketDef = await widget.manifest
        .getDefinition<DestinyInventoryBucketDefinition>(widget.bucketHash);
    var character = widget.profile.getCharacter(widget.characterId);
    ItemWithOwner item = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickTransferScreen(
          bucketDefinition: bucketDef,
          classType: character.classType,
          characterId: widget.characterId,
        ),
      ),
    );
    if (item != null) {
      InventoryService().transfer(item.item, item.ownerId,
          ItemDestination.Character, widget.characterId);
    }
  }

  void onLongPress(context) {
    SelectionService().activateMultiSelect();
    SelectionService().addItem(ItemWithOwner(widget.item, widget.characterId));
    setState(() {});
  }

  void onTap(BuildContext context) {
    if (SelectionService().multiselectActivated) {
      onLongPress(context);
      return;
    }
    if (UserSettingsService().tapToSelect) {
      onTapSelect(context);
    } else {
      onTapDetails(context);
    }
  }

  void onDoubleTap(BuildContext context) {
    if (UserSettingsService().tapToSelect) {
      onTapDetails(context);
    }
  }

  void onTapSelect(context) {
    if (selected) {
      SelectionService().clear();
    } else {
      SelectionService()
          .setItem(ItemWithOwner(widget.item, widget.characterId));
    }
  }

  void onTapDetails(context) {
    if (definition == null) {
      return;
    }
    SelectionService().clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          item: widget.item,
          definition: definition,
          instanceInfo: instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context) {
    if (widget.item == null) {
      return buildEmpty(context);
    }
    if (definition == null) {
      return buildEmpty(context);
    }

    switch (widget.density) {
      case ContentDensity.MINIMAL:
        return buildMinimal(context);

      case ContentDensity.MEDIUM:
        return buildMedium(context);

      case ContentDensity.FULL:
        return buildFull(context);
    }

    return BaseInventoryItemWidget(
      widget.item,
      definition,
      instanceInfo,
      characterId: widget.characterId,
      uniqueId: uniqueId,
    );
  }

  Widget buildEmpty(BuildContext context) {
    switch (widget.bucketHash) {
      case InventoryBucket.engrams:
        {
          return EmptyEngramInventoryItemWidget(uniqueId: uniqueId);
        }
      default:
        {
          if (widget.item == null && quickTransferAvailable) {
            return QuickTransferDestinationItemWidget();
          }
          return LoadingInventoryItemWidget();
        }
    }
  }

  Widget buildMinimal(BuildContext context) {
    var type = definition?.itemType;
    if (type == DestinyItemType.None &&
        definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      type = DestinyItemType.Subclass;
    }
    switch (type) {
      case DestinyItemType.Armor:
        {
          return MinimalArmorInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Weapon:
        {
          return MinimalWeaponInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Engram:
        {
          return MinimalEngramInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      default:
        return MinimalBaseInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }

  Widget buildMedium(BuildContext context) {
    var type = definition?.itemType;
    if (type == DestinyItemType.None &&
        definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      type = DestinyItemType.Subclass;
    }
    switch (type) {
      case DestinyItemType.Subclass:
        return MediumSubclassInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
      case DestinyItemType.Weapon:
        return MediumWeaponInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );

      case DestinyItemType.Armor:
        return MediumArmorInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
      case DestinyItemType.Emblem:
        return MediumEmblemInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );

      default:
        return MediumBaseInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }

  Widget buildFull(BuildContext context) {
    var type = definition?.itemType;
    if (type == DestinyItemType.None &&
        definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      type = DestinyItemType.Subclass;
    }
    switch (type) {
      case DestinyItemType.Subclass:
        {
          return SubclassInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      case DestinyItemType.Weapon:
        {
          return WeaponInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Armor:
        {
          return ArmorInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Emblem:
        {
          return EmblemInventoryItemWidget(
            widget.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      default:
        return BaseInventoryItemWidget(
          widget.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }
}
