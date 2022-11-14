// @dart=2.9

import 'dart:async';
import 'dart:math';

import 'package:bungie_api/enums/destiny_item_type.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/inventory/inventory.bloc.dart';
import 'package:little_light/pages/item_details/item_details.page_route.dart';
import 'package:little_light/pages/item_search/quick_transfer.screen.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/inventory/inventory.package.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/selection/selection.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
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
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum ContentDensity { MINIMAL, MEDIUM, FULL }

class InventoryItemWrapperWidget extends StatefulWidget {
  final ItemWithOwner item;
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

class InventoryItemWrapperWidgetState<T extends InventoryItemWrapperWidget> extends State<T>
    with
        UserSettingsConsumer,
        ProfileConsumer,
        InventoryConsumer,
        ManifestConsumer,
        NotificationConsumer,
        SelectionConsumer {
  InventoryBloc inventoryBloc(BuildContext context) => context.read<InventoryBloc>();

  DestinyInventoryItemDefinition definition;
  String uniqueId;
  bool selected = false;

  StreamSubscription<List<ItemWithOwner>> selectionSubscription;
  StreamSubscription<NotificationEvent> stateSubscription;

  DestinyItemComponent get item => widget.item?.item;
  ItemWithOwner get itemWithOwner => widget.item;

  DestinyItemInstanceComponent get instanceInfo {
    return profile.getInstanceInfo(this.item.itemInstanceId);
  }

  static int queueSize = 0;

  @override
  void initState() {
    uniqueId = Uuid().v4();
    this.definition = manifest.getDefinitionFromCache<DestinyInventoryItemDefinition>(this.item?.itemHash);

    super.initState();
    if (this.item != null && this.definition == null) {
      getDefinitions();
    }

    selectionSubscription = selection.broadcaster.listen((event) {
      if (this.item == null) return;
      if (!mounted) return;
      var isSelected = selection.isSelected(itemWithOwner);
      if (isSelected != selected) {
        selected = isSelected;
        setState(() {});
      }
    });
    stateSubscription = notifications.listen((event) {
      if (!mounted) return;
      if (event.type == NotificationType.itemStateUpdate &&
          event.item.itemHash == this.item?.itemHash &&
          event.item.itemInstanceId == this.item?.itemInstanceId) {
        uniqueId = Uuid().v4();
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
    if (this.item == null) {
      return false;
    }
    return manifest.isLoaded<DestinyInventoryItemDefinition>(this.item.itemHash);
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
    definition = await manifest.getDefinition<DestinyInventoryItemDefinition>(this.item.itemHash);
    if (mounted) {
      setState(() {});
    }
    queueSize--;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: Key("item ${this.item?.itemInstanceId} $uniqueId"),
      children: [
        Positioned.fill(child: buildCrossfade(context)),
        selected
            ? Container(
                foregroundDecoration: BoxDecoration(border: Border.all(color: Colors.lightBlue.shade400, width: 2)),
              )
            : Container(),
        buildTapHandler(context)
      ],
    );
  }

  Widget buildCrossfade(BuildContext context) {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 500),
      firstChild: buildEmpty(context),
      secondChild: buildItem(context),
      crossFadeState: definition == null ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }

  Widget buildTapHandler(BuildContext context) {
    if (this.item == null && quickTransferAvailable) {
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
    if (this.item != null) {
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
    var bucketDef = await manifest.getDefinition<DestinyInventoryBucketDefinition>(widget.bucketHash);
    var character = profile.getCharacter(widget.characterId);
    ItemWithOwner item = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickTransferScreen(
          context,
          bucketDefinition: bucketDef,
          classType: character.classType,
          characterId: widget.characterId,
        ),
      ),
    );
    if (item != null) {
      await inventoryBloc(context).transfer(item.item, widget.characterId);
    }
  }

  void onLongPress(context) {
    selection.activateMultiSelect();
    selection.addItem(itemWithOwner);
    setState(() {});
  }

  void onTap(BuildContext context) {
    if (selection.multiselectActivated) {
      onLongPress(context);
      return;
    }
    if (userSettings.tapToSelect) {
      onTapSelect(context);
    } else {
      onTapDetails(context);
    }
  }

  void onDoubleTap(BuildContext context) {
    if (userSettings.tapToSelect) {
      onTapDetails(context);
    }
  }

  void onTapSelect(context) {
    if (selected) {
      selection.clear();
    } else {
      selection.setItem(itemWithOwner);
    }
  }

  void onTapDetails(context) {
    if (definition == null) {
      return;
    }
    selection.clear();
    Navigator.push(
      context,
      ItemDetailsPageRoute(
        item: widget.item,
        heroKey: uniqueId,
      ),
    );
  }

  Widget buildItem(BuildContext context) {
    if (this.item == null) {
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
      this.item,
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
          if (this.item == null && quickTransferAvailable) {
            return QuickTransferDestinationItemWidget();
          }
          return LoadingInventoryItemWidget();
        }
    }
  }

  Widget buildMinimal(BuildContext context) {
    var type = definition?.itemType;
    if (type == DestinyItemType.None && definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      type = DestinyItemType.Subclass;
    }
    switch (type) {
      case DestinyItemType.Armor:
        {
          return MinimalArmorInventoryItemWidget(
            this.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Weapon:
        {
          return MinimalWeaponInventoryItemWidget(
            this.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Engram:
        {
          return MinimalEngramInventoryItemWidget(
            this.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      default:
        return MinimalBaseInventoryItemWidget(
          this.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }

  Widget buildMedium(BuildContext context) {
    var type = definition?.itemType;
    if (type == DestinyItemType.None && definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      type = DestinyItemType.Subclass;
    }
    switch (type) {
      case DestinyItemType.Subclass:
        return MediumSubclassInventoryItemWidget(
          this.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
      case DestinyItemType.Weapon:
        return MediumWeaponInventoryItemWidget(
          this.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );

      case DestinyItemType.Armor:
        return MediumArmorInventoryItemWidget(
          this.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
      case DestinyItemType.Emblem:
        return MediumEmblemInventoryItemWidget(
          this.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );

      default:
        return MediumBaseInventoryItemWidget(
          this.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }

  Widget buildFull(BuildContext context) {
    var type = definition?.itemType;
    if (type == DestinyItemType.None && definition?.inventory?.bucketTypeHash == InventoryBucket.subclass) {
      type = DestinyItemType.Subclass;
    }
    switch (type) {
      case DestinyItemType.Subclass:
        {
          return SubclassInventoryItemWidget(
            this.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      case DestinyItemType.Weapon:
        {
          return WeaponInventoryItemWidget(
            this.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Armor:
        {
          return ArmorInventoryItemWidget(
            this.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }

      case DestinyItemType.Emblem:
        {
          return EmblemInventoryItemWidget(
            this.item,
            definition,
            instanceInfo,
            characterId: widget.characterId,
            uniqueId: uniqueId,
          );
        }
      default:
        return BaseInventoryItemWidget(
          this.item,
          definition,
          instanceInfo,
          characterId: widget.characterId,
          uniqueId: uniqueId,
        );
    }
  }
}
