import 'package:drag_list/drag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/models/item_notes_tag.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/pages/add_wishlist.screen.dart';
import 'package:little_light/services/littlelight/item_notes.service.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/models/item_sort_parameter.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/utils/platform_capabilities.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/littlelight_custom.dialog.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/center_icon_workaround.dart';
import 'package:little_light/widgets/item_tags/item_tag.widget.dart';
import 'package:little_light/widgets/option_sheets/free_slots_slider.widget.dart';
import 'package:screen/screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with UserSettingsConsumer{
  List<ItemSortParameter> itemOrdering;
  List<ItemSortParameter> pursuitOrdering;
  Set<String> priorityTags;
  List<Wishlist> wishlists;

  @override
  void initState() {
    super.initState();
    itemOrdering = userSettings.itemOrdering;
    pursuitOrdering = userSettings.pursuitOrdering;
    priorityTags = userSettings.priorityTags;
    wishlists = WishlistsService().getWishlists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            enableFeedback: false,
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: TranslatedTextWidget("Settings"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
        subtitle:
            TranslatedTextWidget("Keep device awake while the app is open"),
        trailing: Switch(
          value: userSettings.keepAwake,
          onChanged: (val) {
            userSettings.keepAwake = val;
            setState(() {});
            Screen.keepOn(val);
          },
        ));
  }

  buildTapToSelect(BuildContext context) {
    return ListTile(
        title: TranslatedTextWidget(
          "Tap to select",
        ),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
        subtitle:
            TranslatedTextWidget("Open keyboard automatically in quick search"),
        trailing: Switch(
          value: userSettings.autoOpenKeyboard,
          onChanged: (val) {
            userSettings.autoOpenKeyboard = val;
            setState(() {});
          },
        ));
  }

  buildWishlists(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildWishlistsList(context),
        Container(
            padding: EdgeInsets.all(8),
            child: TranslatedTextWidget(
                "You can add community curated wishlists (aka DIM™️ wishlists) on Little Light to check your god rolls.")),
        Container(
          color: Colors.grey.shade400,
          height: 1,
          margin: EdgeInsets.all(8),
        ),
        Row(children: [
          Expanded(
            child: Container(),
          ),
          ElevatedButton(
            child: TranslatedTextWidget("Add Wishlist"),
            onPressed: () async {
              Wishlist wishlist = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWishlistScreen(),
                  ));
              if (wishlist is Wishlist) {
                showDialog(
                    barrierDismissible: false,
                    useRootNavigator: true,
                    context: context,
                    builder: (context) => buildProcessingDialog(context));
                wishlists = await WishlistsService().addWishlist(wishlist);
                Navigator.of(context).pop();
                setState(() {});
              }
            },
          )
        ])
      ],
    );
  }

  SimpleDialog buildProcessingDialog(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        Container(
            width: 96,
            height: 96,
            child: Shimmer.fromColors(
              baseColor: Colors.blueGrey.shade300,
              highlightColor: Colors.white,
              child: Image.asset("assets/anim/loading.webp"),
            )),
        Center(child: TranslatedTextWidget("Processing wishlists"))
      ],
    );
  }

  buildWishlistsList(BuildContext context) {
    return Column(
        children: wishlists
            .map((w) => Container(
                padding: EdgeInsets.all(8),
                child: Material(
                    color: Colors.blueGrey.shade600,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Material(
                              color: Colors.lightBlue.shade600,
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    w.name ?? "",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))),
                          Container(
                              padding: EdgeInsets.all(8).copyWith(bottom: 0),
                              child: Linkify(
                                  text: w.description ?? "",
                                  linkStyle: TextStyle(color: Colors.white),
                                  onOpen: (link) =>
                                      launch(link.url, forceSafariVC: true))),
                          Container(
                              padding: EdgeInsets.all(8),
                              child: Row(children: [
                                Expanded(child: Container()),
                                ElevatedButton(
                                    child: TranslatedTextWidget("Update"),
                                    onPressed: () async {
                                      showDialog(
                                          barrierDismissible: false,
                                          useRootNavigator: true,
                                          context: context,
                                          builder: (context) =>
                                              buildProcessingDialog(context));
                                      wishlists = await WishlistsService()
                                          .removeWishlist(w);
                                      wishlists = await WishlistsService()
                                          .addWishlist(w);
                                      Navigator.of(context).pop();
                                      setState(() {});
                                      WishlistsService().countBuilds();
                                    }),
                                Container(
                                  width: 8,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).errorColor,
                                    ),
                                    child: TranslatedTextWidget("Remove"),
                                    onPressed: () async {
                                      showDialog(
                                          barrierDismissible: false,
                                          useRootNavigator: true,
                                          context: context,
                                          builder: (context) =>
                                              buildProcessingDialog(context));
                                      wishlists = await WishlistsService()
                                          .removeWishlist(w);
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    })
                              ]))
                        ]))))
            .toList());
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

  buildCharacterOrderItem(
      BuildContext context, Widget label, CharacterSortParameterType type) {
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
            userSettings.characterOrdering =
                userSettings.characterOrdering;
            setState(() {});
          },
        ),
      ),
    );
  }

  buildItemOrderList(BuildContext context) {
    return Container(
        height: (itemOrdering.length + 1) * 48.0,
        child: DragList<ItemSortParameter>(
          items: itemOrdering,
          itemExtent: 48,
          handleBuilder: (context) => buildHandle(context),
          onItemReorder: (oldIndex, newIndex) {
            var removed = itemOrdering.removeAt(oldIndex);
            itemOrdering.insert(newIndex, removed);
            userSettings.itemOrdering = itemOrdering;
          },
          itemBuilder: (context, parameter, handle) =>
              buildSortItem(context, parameter.value, handle, onSave: () {
            userSettings.itemOrdering = itemOrdering;
          }),
        ));
  }

  Widget buildHandle(BuildContext context) {
    return GestureDetector(
        onVerticalDragStart: (_) {},
        onVerticalDragDown: (_) {},
        child: AspectRatio(
            aspectRatio: 1,
            child:
                Container(color: Colors.transparent, child: Icon(Icons.menu))));
  }

  buildPursuitOrderList(BuildContext context) {
    return Container(
        height: (pursuitOrdering.length + 1) * 48.0,
        child: DragList<ItemSortParameter>(
          items: pursuitOrdering,
          itemExtent: 48,
          handleBuilder: (context) => buildHandle(context),
          onItemReorder: (oldIndex, newIndex) {
            var removed = pursuitOrdering.removeAt(oldIndex);
            pursuitOrdering.insert(newIndex, removed);
            userSettings.pursuitOrdering = pursuitOrdering;
          },
          itemBuilder: (context, parameter, handle) =>
              buildSortItem(context, parameter.value, handle, onSave: () {
            userSettings.pursuitOrdering = pursuitOrdering;
          }),
        ));
  }

  Widget buildPriorityTags(BuildContext context) {
    var tags = ItemNotesService().tagsByIds(priorityTags);
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
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        child: CenterIconWorkaround(
                            FontAwesomeIcons.solidTimesCircle,
                            size: 16,
                            color: Colors.red)),
                    onClick: () {
                      priorityTags.remove(t.tagId);
                      userSettings.priorityTags = priorityTags;
                      setState(() {});
                    },
                  ))
              .followedBy([
            ItemTagWidget(
                ItemNotesTag(
                    icon: null, name: "Add Tag", backgroundColorHex: "#03A9f4"),
                includeLabel: true,
                padding: 4,
                trailing:
                    CenterIconWorkaround(FontAwesomeIcons.plusCircle, size: 18),
                onClick: () => openAddTagDialog(context)),
          ]).toList(),
        ));
  }

  openAddTagDialog(BuildContext context) async {
    var tags = ItemNotesService().getAvailableTags();
    var result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return LittleLightCustomDialog.withHorizontalButtons(
              SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: tags
                    .map((t) => Container(
                        margin: EdgeInsets.only(top: 8),
                        child: (t?.custom ?? false)
                            ? Row(children: [
                                Expanded(
                                    child: ItemTagWidget(
                                  t,
                                  includeLabel: true,
                                  padding: 4,
                                  onClick: () {
                                    Navigator.of(context).pop(t.tagId);
                                  },
                                )),
                                Container(
                                  width: 8,
                                ),
                              ])
                            : ItemTagWidget(
                                t,
                                includeLabel: true,
                                padding: 4,
                                onClick: () {
                                  Navigator.of(context).pop(t.tagId);
                                },
                              )))
                    .toList(),
              )),
              maxWidth: 400,
              buttons: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.comfortable,
                    ),
                    child: TranslatedTextWidget("Cancel",
                        uppercase: true,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
              title: TranslatedTextWidget(
                'Select tag',
                uppercase: true,
              ));
        });

    if (result != null) {
      priorityTags.add(result);
      userSettings.priorityTags = priorityTags;
      setState(() {});
    }
  }

  Widget buildSortItem(
      BuildContext context, ItemSortParameter parameter, Widget handle,
      {@required Function onSave}) {
    return Container(
        key: Key("param_${parameter.type}"),
        child: Container(
            color: parameter.active
                ? Colors.blueGrey.shade700
                : Colors.blueGrey.shade800,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              handle,
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

  Widget buildDirectionButton(ItemSortParameter parameter, int direction,
      {@required Function onSave}) {
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
          child: Icon(
              direction > 0
                  ? FontAwesomeIcons.chevronUp
                  : FontAwesomeIcons.chevronDown,
              size: 14),
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
