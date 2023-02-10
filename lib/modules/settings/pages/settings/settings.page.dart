// @dart=2.9

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/modules/settings/pages/add_wishlist/add_wishlist.page_route.dart';
import 'package:little_light/modules/settings/widgets/wishlist_file_item.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/dialogs/busy.dialog.dart';
import 'package:little_light/widgets/dialogs/tags/select_tag.dialog.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';
import 'package:little_light/widgets/item_tags/item_tag.widget.dart';
import 'package:little_light/widgets/option_sheets/free_slots_slider.widget.dart';
import 'package:wakelock/wakelock.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with UserSettingsConsumer, WishlistsConsumer, ItemNotesConsumer {
  List<ItemSortParameter> itemOrdering;
  List<ItemSortParameter> pursuitOrdering;
  Set<String> priorityTags;
  List<WishlistFile> wishlists;

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  asyncInit() async {
    itemOrdering = userSettings.itemOrdering;
    pursuitOrdering = userSettings.pursuitOrdering;
    priorityTags = userSettings.priorityTags;
    wishlists = await wishlistsService.getWishlists();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings".translate(context)),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              buildTapToSelect(context),
              Container(height: 16),
              buildKeepAwake(context),
              Container(height: 16),
              buildAutoOpenSearch(context),
              Container(height: 16),
              HeaderWidget(
                  child: Text(
                "Default free slots".translate(context).toUpperCase(),
              )),
              buildDefaultFreeSlots(context),
              HeaderWidget(
                  child: Text(
                "Wishlists".translate(context).toUpperCase(),
              )),
              buildWishlists(context),
              Container(height: 16),
              HeaderWidget(
                  child: Text(
                "Order characters by".translate(context).toUpperCase(),
              )),
              buildCharacterOrdering(context),
              Container(height: 32),
              HeaderWidget(
                  child: Text(
                "Order items by".translate(context).toUpperCase(),
              )),
              buildItemOrderList(context),
              HeaderWidget(
                  child: Text(
                "Order pursuits by".translate(context).toUpperCase(),
              )),
              buildPursuitOrderList(context),
              HeaderWidget(
                  child: Text(
                "Priority Tags".translate(context).toUpperCase(),
              )),
              buildPriorityTags(context),
              Container(height: 32),
            ])));
  }

  buildKeepAwake(BuildContext context) {
    if (!PlatformCapabilities.keepScreenOnAvailable) {
      return Container();
    }
    return ListTile(
        title: Text(
          "Keep Awake".translate(context).toUpperCase(),
        ),
        subtitle: Text("Keep device awake while the app is open".translate(context)),
        trailing: Switch(
          value: userSettings.keepAwake,
          onChanged: (val) {
            userSettings.keepAwake = val;
            setState(() {});
            Wakelock.toggle(enable: val);
          },
        ));
  }

  buildTapToSelect(BuildContext context) {
    return ListTile(
        title: Text(
          "Tap to select".translate(context).toUpperCase(),
        ),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(
            "Tapping on items will select them for quick transfer and equip instead of opening details"
                .translate(context),
          ),
          Text("Double tap for details".translate(context)),
        ]),
        trailing: Switch(
          value: userSettings.tapToSelect,
          onChanged: (val) {
            userSettings.tapToSelect = val;
            setState(() {});
          },
        ));
  }

  buildAutoOpenSearch(BuildContext context) {
    return ListTile(
        title: Text(
          "Auto open Keyboard".translate(context),
        ),
        subtitle: Text("Open keyboard automatically in quick search".translate(context)),
        trailing: Switch(
          value: userSettings.autoOpenKeyboard,
          onChanged: (val) {
            userSettings.autoOpenKeyboard = val;
            setState(() {});
          },
        ));
  }

  buildWishlists(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildWishlistsList(context),
            Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  "You can add community curated wishlists (or your custom ones) on Little Light to check your rolls."
                      .translate(context),
                )),
            Row(children: [
              Expanded(child: Container()),
              ElevatedButton(
                child: Text("Add Wishlist".translate(context), textAlign: TextAlign.center),
                onPressed: () async {
                  await Navigator.push(context, AddWishlistPageRoute());
                  wishlists = await wishlistsService.getWishlists();
                  setState(() {});
                },
              ),
            ])
          ],
        ));
  }

  Future<T> showWishlistsProcessing<T>(BuildContext context, Future<T> future) {
    return Navigator.of(context)
        .push(BusyDialogRoute(context, label: Text("Processing wishlists".translate(context)), awaitFuture: future));
  }

  buildWishlistsList(BuildContext context) {
    if (wishlists == null) return Container();
    return Container(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
            children: wishlists
                .map((e) => WishlistFileItem(file: e, actions: [
                      ElevatedButton(
                        onPressed: () async {
                          final awaitable = () async {
                            await wishlistsService.removeWishlist(e);
                            wishlists = await wishlistsService.getWishlists();
                          };
                          await Navigator.push(context, BusyDialogRoute(context, awaitFuture: awaitable()));
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                            primary: LittleLightTheme.of(context).errorLayers, visualDensity: VisualDensity.compact),
                        child: Text("Remove".translate(context)),
                      )
                    ]))
                .toList()));
  }

  buildDefaultFreeSlots(BuildContext context) {
    return FreeSlotsSliderWidget(
        suppressLabel: true,
        initialValue: userSettings.defaultFreeSlots,
        onChanged: (value) {
          userSettings.defaultFreeSlots = value;
        });
  }

  buildCharacterOrdering(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(4),
        child: IntrinsicHeight(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildCharacterOrderItem(
                context,
                Text(
                  "Last played".translate(context),
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.LastPlayed),
            Container(
              width: 4,
            ),
            buildCharacterOrderItem(
                context,
                Text(
                  "First created".translate(context),
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.FirstCreated),
            Container(
              width: 4,
            ),
            buildCharacterOrderItem(
                context,
                Text(
                  "Last created".translate(context),
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.LastCreated),
          ],
        )));
  }

  buildCharacterOrderItem(BuildContext context, Widget label, CharacterSortParameterType type) {
    var selected = type == userSettings.characterOrdering.type;
    return Expanded(
      child: Material(
        color: selected ? Colors.lightBlue : Colors.blueGrey,
        child: InkWell(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            alignment: Alignment.center,
            child: label,
          ),
          onTap: () {
            userSettings.characterOrdering.type = type;
            userSettings.characterOrdering = userSettings.characterOrdering;
            setState(() {});
          },
        ),
      ),
    );
  }

  buildItemOrderList(BuildContext context) {
    return SizedBox(
        height: (itemOrdering.length + 1) * 48.0,
        child: ReorderableList(
          itemCount: itemOrdering.length,
          itemBuilder: (context, index) {
            final item = itemOrdering[index];
            return buildSortItem(context, item, index, onSave: () {
              userSettings.itemOrdering = itemOrdering;
            });
          },
          itemExtent: 48,
          onReorder: (oldIndex, newIndex) {
            final removed = itemOrdering.removeAt(oldIndex);
            itemOrdering.insert(newIndex, removed);
            userSettings.itemOrdering = itemOrdering;
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: const Icon(Icons.menu))));
  }

  buildPursuitOrderList(BuildContext context) {
    return SizedBox(
        height: (pursuitOrdering.length + 1) * 48.0,
        child: ReorderableList(
          itemCount: pursuitOrdering.length,
          itemExtent: 48,
          onReorder: (oldIndex, newIndex) {
            var removed = pursuitOrdering.removeAt(oldIndex);
            pursuitOrdering.insert(newIndex, removed);
            userSettings.pursuitOrdering = pursuitOrdering;
          },
          itemBuilder: (context, index) {
            final item = pursuitOrdering[index];
            return buildSortItem(context, item, index, onSave: () {
              userSettings.pursuitOrdering = pursuitOrdering;
            });
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ));
  }

  Widget buildPriorityTags(BuildContext context) {
    var tags = itemNotes.tagsByIds(priorityTags);
    return Container(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          runSpacing: 4,
          spacing: 4,
          children: tags
              .map((t) => ItemTagWidget(
                    t,
                    includeLabel: true,
                    padding: 4,
                    trailing: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.onSurface),
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        child: const CenterIconWorkaround(FontAwesomeIcons.solidTimesCircle, size: 16, color: Colors.red)),
                    onClick: () {
                      userSettings.removePriorityTag(t);
                      setState(() {});
                    },
                  ))
              .followedBy([
            ItemTagWidget(ItemNotesTag(icon: null, name: "Add Tag", backgroundColorHex: "#03A9f4"),
                includeLabel: true,
                padding: 4,
                trailing: const CenterIconWorkaround(FontAwesomeIcons.plusCircle, size: 18),
                onClick: () => openAddTagDialog(context)),
          ]).toList(),
        ));
  }

  void openAddTagDialog(BuildContext context) async {
    final tag = await Navigator.of(context).push(SelectTagDialogRoute(context));
    if (tag != null) {
      userSettings.addPriorityTag(tag);
    }
    setState(() {});
  }

  Widget buildSortItem(BuildContext context, ItemSortParameter parameter, int index, {@required Function onSave}) {
    return Material(
        key: Key("param_${parameter.type}"),
        child: Container(
            color: parameter.active
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.secondaryContainer,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              buildHandle(context, index),
              Container(width: 8),
              Expanded(child: buildSortLabel(parameter)),
              buildDirectionButton(parameter, 1, onSave: onSave),
              Container(width: 4),
              buildDirectionButton(parameter, -1, onSave: onSave),
              Container(width: 8),
              Container(
                  padding: const EdgeInsets.all(8),
                  child: Switch(
                    onChanged: (value) {
                      parameter.active = value;
                      onSave();
                      setState(() {});
                    },
                    value: parameter.active,
                  ))
            ])));
  }

  Widget buildDirectionButton(ItemSortParameter parameter, int direction, {@required Function onSave}) {
    var selected = parameter.direction == direction;
    if (!parameter.active) return Container();
    return SizedBox(
      width: 20,
      height: 20,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: selected
                ? Theme.of(context).toggleButtonsTheme.selectedColor
                : Theme.of(context).toggleButtonsTheme.color,
            padding: const EdgeInsets.all(0),
          ),
          child: Icon(direction > 0 ? FontAwesomeIcons.chevronUp : FontAwesomeIcons.chevronDown, size: 14),
          onPressed: () {
            parameter.direction = direction;
            setState(() {});
            onSave();
          }),
    );
  }

  Widget buildSortLabel(ItemSortParameter parameter) {
    switch (parameter.type) {
      case ItemSortParameterType.PowerLevel:
        return Text(
          "Power Level".translate(context).toUpperCase(),
        );

      case ItemSortParameterType.TierType:
        return Text(
          "Rarity".translate(context).toUpperCase(),
        );

      case ItemSortParameterType.ExpirationDate:
        return Text(
          "Expiration Date".translate(context).toUpperCase(),
        );
      case ItemSortParameterType.Name:
        return Text(
          "Name".translate(context).toUpperCase(),
        );
      case ItemSortParameterType.SubType:
        return Text(
          "Type".translate(context).toUpperCase(),
        );
      case ItemSortParameterType.ClassType:
        return Text(
          "Class Type".translate(context).toUpperCase(),
        );
      case ItemSortParameterType.AmmoType:
        return Text(
          "Ammo Type".translate(context).toUpperCase(),
        );
      case ItemSortParameterType.BucketHash:
        return Text(
          "Slot".translate(context).toUpperCase(),
        );
      case ItemSortParameterType.Quantity:
        return Text(
          "Quantity".translate(context).toUpperCase(),
        );

      case ItemSortParameterType.QuestGroup:
        return Text(
          "Group".translate(context).toUpperCase(),
        );

      case ItemSortParameterType.ItemOwner:
        return Text(
          "Item Holder".translate(context).toUpperCase(),
        );

      case ItemSortParameterType.StatTotal:
        return Text(
          "Stats Total".translate(context).toUpperCase(),
        );

      case ItemSortParameterType.MasterworkStatus:
        return Text(
          "Masterwork Status".translate(context).toUpperCase(),
        );
        break;

      case ItemSortParameterType.Stat:
        return Text(
          "Stat".translate(context).toUpperCase(),
        );
        break;

      case ItemSortParameterType.DamageType:
        return Text(
          "Damage Type".translate(context).toUpperCase(),
        );
    }
    return Text(
      parameter.type.toString(),
    );
  }
}
