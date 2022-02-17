// @dart=2.9

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/pages/settings/add_wishlist.page_route.dart';
import 'package:little_light/pages/settings/widgets/wishlist_file_item.dart';
import 'package:little_light/services/littlelight/item_notes.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
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
          title: TranslatedTextWidget("Settings"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
              buildTapToSelect(context),
              Container(height: 16),
              buildKeepAwake(context),
              Container(height: 16),
              buildAutoOpenSearch(context),
              Container(height: 16),
              HeaderWidget(
                  child: TranslatedTextWidget(
                "Default free slots",
                uppercase: true,
              )),
              buildDefaultFreeSlots(context),
              HeaderWidget(
                  child: TranslatedTextWidget(
                "Wishlists",
                uppercase: true,
              )),
              buildWishlists(context),
              Container(height: 16),
              HeaderWidget(
                  child: TranslatedTextWidget(
                "Order characters by",
                uppercase: true,
              )),
              buildCharacterOrdering(context),
              Container(height: 32),
              HeaderWidget(
                  child: TranslatedTextWidget(
                "Order items by",
                uppercase: true,
              )),
              buildItemOrderList(context),
              HeaderWidget(
                  child: TranslatedTextWidget(
                "Order pursuits by",
                uppercase: true,
              )),
              buildPursuitOrderList(context),
              HeaderWidget(
                  child: TranslatedTextWidget(
                "Priority Tags",
                uppercase: true,
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
        title: TranslatedTextWidget(
          "Keep Awake",
        ),
        subtitle: TranslatedTextWidget("Keep device awake while the app is open"),
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
        title: TranslatedTextWidget(
          "Tap to select",
        ),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TranslatedTextWidget(
              "Tapping on items will select them for quick transfer and equip instead of opening details"),
          TranslatedTextWidget("Double tap for details"),
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
        title: TranslatedTextWidget(
          "Auto open Keyboard",
        ),
        subtitle: TranslatedTextWidget("Open keyboard automatically in quick search"),
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
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildWishlistsList(context),
            Container(
                padding: EdgeInsets.all(8),
                child: TranslatedTextWidget(
                    "You can add community curated wishlists (or your custom ones) on Little Light to check your rolls.")),
            Row(children: [
              Expanded(child: Container()),
              ElevatedButton(
                child: TranslatedTextWidget("Add Wishlist", textAlign: TextAlign.center),
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
        .push(BusyDialogRoute(context, label: TranslatedTextWidget("Processing wishlists"), awaitFuture: future));
  }

  buildWishlistsList(BuildContext context) {
    if (wishlists == null) return Container();
    return Container(
        padding: EdgeInsets.only(top: 8),
        child: Column(
            children: wishlists
                .map((e) => WishlistFileItem(file: e, actions: [
                      ElevatedButton(
                        onPressed: () async {
                          final awaitable = () async {
                            await wishlistsService.removeWishlist(e);
                            this.wishlists = await wishlistsService.getWishlists();
                          };
                          await Navigator.push(context, BusyDialogRoute(context, awaitFuture: awaitable()));
                          setState(() {});
                        },
                        child: TranslatedTextWidget("Remove"),
                        style: ElevatedButton.styleFrom(
                            primary: LittleLightTheme.of(context).errorLayers, visualDensity: VisualDensity.compact),
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
        padding: EdgeInsets.all(4),
        child: IntrinsicHeight(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildCharacterOrderItem(
                context,
                TranslatedTextWidget(
                  "Last played",
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.LastPlayed),
            Container(
              width: 4,
            ),
            buildCharacterOrderItem(
                context,
                TranslatedTextWidget(
                  "First created",
                  textAlign: TextAlign.center,
                ),
                CharacterSortParameterType.FirstCreated),
            Container(
              width: 4,
            ),
            buildCharacterOrderItem(
                context,
                TranslatedTextWidget(
                  "Last created",
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
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: label,
            alignment: Alignment.center,
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
    return Container(
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
          physics: NeverScrollableScrollPhysics(),
        ));
  }

  Widget buildHandle(BuildContext context, int index) {
    return ReorderableDragStartListener(
        index: index,
        child: AspectRatio(aspectRatio: 1, child: Container(color: Colors.transparent, child: Icon(Icons.menu))));
  }

  buildPursuitOrderList(BuildContext context) {
    return Container(
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
          physics: NeverScrollableScrollPhysics(),
        ));
  }

  Widget buildPriorityTags(BuildContext context) {
    var tags = itemNotes.tagsByIds(priorityTags);
    return Container(
        padding: EdgeInsets.all(8),
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
                        child: CenterIconWorkaround(FontAwesomeIcons.solidTimesCircle, size: 16, color: Colors.red)),
                    onClick: () {
                      userSettings.removePriorityTag(t);
                      setState(() {});
                    },
                  ))
              .followedBy([
            ItemTagWidget(ItemNotesTag(icon: null, name: "Add Tag", backgroundColorHex: "#03A9f4"),
                includeLabel: true,
                padding: 4,
                trailing: CenterIconWorkaround(FontAwesomeIcons.plusCircle, size: 18),
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
                  padding: EdgeInsets.all(8),
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
    return Container(
      width: 20,
      height: 20,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: selected
                ? Theme.of(context).toggleButtonsTheme.selectedColor
                : Theme.of(context).toggleButtonsTheme.color,
            padding: EdgeInsets.all(0),
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
        return TranslatedTextWidget(
          "Power Level",
          uppercase: true,
        );

      case ItemSortParameterType.TierType:
        return TranslatedTextWidget(
          "Rarity",
          uppercase: true,
        );

      case ItemSortParameterType.ExpirationDate:
        return TranslatedTextWidget(
          "Expiration Date",
          uppercase: true,
        );
      case ItemSortParameterType.Name:
        return TranslatedTextWidget(
          "Name",
          uppercase: true,
        );
      case ItemSortParameterType.SubType:
        return TranslatedTextWidget(
          "Type",
          uppercase: true,
        );
      case ItemSortParameterType.ClassType:
        return TranslatedTextWidget(
          "Class Type",
          uppercase: true,
        );
      case ItemSortParameterType.AmmoType:
        return TranslatedTextWidget(
          "Ammo Type",
          uppercase: true,
        );
      case ItemSortParameterType.BucketHash:
        return TranslatedTextWidget(
          "Slot",
          uppercase: true,
        );
      case ItemSortParameterType.Quantity:
        return TranslatedTextWidget(
          "Quantity",
          uppercase: true,
        );

      case ItemSortParameterType.QuestGroup:
        return TranslatedTextWidget("Group", uppercase: true);

      case ItemSortParameterType.ItemOwner:
        return TranslatedTextWidget("Item Holder", uppercase: true);

      case ItemSortParameterType.StatTotal:
        return TranslatedTextWidget("Stats Total", uppercase: true);

      case ItemSortParameterType.MasterworkStatus:
        return TranslatedTextWidget("Masterwork Status", uppercase: true);
        break;

      case ItemSortParameterType.Stat:
        break;

      case ItemSortParameterType.DamageType:
        return TranslatedTextWidget("Damage Type", uppercase: true);
    }
    return Text(
      parameter.type.toString(),
    );
  }
}
