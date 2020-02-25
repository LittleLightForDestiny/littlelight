import 'package:drag_list/drag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/screens/add_wishlist.screen.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';
import 'package:little_light/services/user_settings/character_sort_parameter.dart';
import 'package:little_light/services/user_settings/item_sort_parameter.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';

import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/flutter/smaller_switch.dart';
import 'package:little_light/widgets/option_sheets/free_slots_slider.widget.dart';
import 'package:screen/screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  final UserSettingsService settings = new UserSettingsService();
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<ItemSortParameter> itemOrdering;
  List<ItemSortParameter> pursuitOrdering;
  List<Wishlist> wishlists;

  @override
  void initState() {
    super.initState();
    itemOrdering = widget.settings.itemOrdering;
    pursuitOrdering = widget.settings.pursuitOrdering;
    wishlists = WishlistsService().getWishlists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: TranslatedTextWidget("Settings"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[
              buildKeepAwake(context),
              Container(height: 16),
              buildAutoOpenSearch(context),
              Container(height: 16),
              HeaderWidget(
                  alignment: Alignment.centerLeft,
                  child: TranslatedTextWidget(
                    "Default free slots",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              buildDefaultFreeSlots(context),
              HeaderWidget(
                  alignment: Alignment.centerLeft,
                  child: TranslatedTextWidget(
                    "Wishlists",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              buildWishlists(context),
              Container(height: 16),
              HeaderWidget(
                  alignment: Alignment.centerLeft,
                  child: TranslatedTextWidget(
                    "Order characters by",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              buildCharacterOrdering(context),
              Container(height: 32),
              HeaderWidget(
                  alignment: Alignment.centerLeft,
                  child: TranslatedTextWidget(
                    "Order items by",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              buildItemOrderList(context),
              HeaderWidget(
                  alignment: Alignment.centerLeft,
                  child: TranslatedTextWidget(
                    "Order pursuits by",
                    uppercase: true,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              buildPursuitOrderList(context)
            ])));
  }

  buildKeepAwake(BuildContext context) {
    return ListTile(
        title: TranslatedTextWidget(
          "Keep Awake",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            TranslatedTextWidget("Keep device awake while the app is open"),
        trailing: Switch(
          value: widget.settings.keepAwake,
          onChanged: (val) {
            widget.settings.keepAwake = val;
            setState(() {});
            Screen.keepOn(val);
          },
        ));
  }

  buildAutoOpenSearch(BuildContext context) {
    return ListTile(
        title: TranslatedTextWidget(
          "Auto open Keyboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            TranslatedTextWidget("Open keyboard automatically in quick search"),
        trailing: Switch(
          value: widget.settings.autoOpenKeyboard,
          onChanged: (val) {
            widget.settings.autoOpenKeyboard = val;
            setState(() {});
            Screen.keepOn(val);
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
          RaisedButton(
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
                                    w.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))),
                          Container(
                              padding: EdgeInsets.all(8).copyWith(bottom: 0),
                              child: Linkify(
                                  text: w.description,
                                  linkStyle: TextStyle(color: Colors.white),
                                  onOpen: (link) =>
                                      launch(link.url, forceSafariVC: true))),
                          Container(
                              padding: EdgeInsets.all(8),
                              child: Row(children: [
                                Expanded(child: Container()),
                                RaisedButton(
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
                                Container(width: 8,),
                                RaisedButton(
                                    color: Theme.of(context).errorColor,
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
        initialValue: widget.settings.defaultFreeSlots,
        onChanged: (value) {
          widget.settings.defaultFreeSlots = value;
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                CharacterSortParameterType.LastCreated),
          ],
        )));
  }

  buildCharacterOrderItem(
      BuildContext context, Widget label, CharacterSortParameterType type) {
    var selected = type == widget.settings.characterOrdering.type;
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
            widget.settings.characterOrdering.type = type;
            widget.settings.characterOrdering =
                widget.settings.characterOrdering;
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
            widget.settings.itemOrdering = itemOrdering;
          },
          itemBuilder: (context, parameter, handle) =>
              buildSortItem(context, parameter, handle, onSave: () {
            widget.settings.itemOrdering = itemOrdering;
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
            widget.settings.pursuitOrdering = pursuitOrdering;
          },
          itemBuilder: (context, parameter, handle) =>
              buildSortItem(context, parameter, handle, onSave: () {
            widget.settings.pursuitOrdering = pursuitOrdering;
          }),
        ));
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
                  child: SmallerSwitch(
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
      child: RaisedButton(
          color: selected ? Colors.lightBlue : Colors.blueGrey,
          padding: EdgeInsets.all(0),
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
    var style = TextStyle(
        fontWeight: FontWeight.bold,
        color: parameter.active ? Colors.white : Colors.grey.shade500);
    switch (parameter.type) {
      case ItemSortParameterType.PowerLevel:
        return TranslatedTextWidget(
          "Power Level",
          uppercase: true,
          style: style,
        );

      case ItemSortParameterType.TierType:
        return TranslatedTextWidget(
          "Rarity",
          uppercase: true,
          style: style,
        );

      case ItemSortParameterType.ExpirationDate:
        return TranslatedTextWidget(
          "Expiration Date",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.Name:
        return TranslatedTextWidget(
          "Name",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.SubType:
        return TranslatedTextWidget(
          "Type",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.ClassType:
        return TranslatedTextWidget(
          "Class Type",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.AmmoType:
        return TranslatedTextWidget(
          "Ammo Type",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.BucketHash:
        return TranslatedTextWidget(
          "Slot",
          uppercase: true,
          style: style,
        );
      case ItemSortParameterType.Quantity:
        return TranslatedTextWidget(
          "Quantity",
          uppercase: true,
          style: style,
        );

      case ItemSortParameterType.QuestGroup:
        return TranslatedTextWidget("Group", uppercase: true, style: style);

      case ItemSortParameterType.ItemOwner:
        return TranslatedTextWidget("Item Holder",
            uppercase: true, style: style);

      case ItemSortParameterType.StatTotal:
        return TranslatedTextWidget("Stats Total",
            uppercase: true, style: style);

      default:
        return Text(
          parameter.type.toString(),
          style: style,
        );
    }
  }
}
