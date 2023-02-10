// @dart=2.9

import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.consumer.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';

class InspectScreen extends StatefulWidget {
  final String membershipId;
  final int membershipType;

  const InspectScreen(this.membershipId, this.membershipType, {Key key}) : super(key: key);

  @override
  InspectScreenState createState() => InspectScreenState();
}

class InspectScreenState extends State<InspectScreen>
    with TickerProviderStateMixin, UserSettingsConsumer, ProfileConsumer {
  TabController charTabController;
  TabController typeTabController;

  get totalCharacterTabs => characters?.length != null ? characters.length : 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (characters == null) {
      return buildLoading(context);
    }
    charTabController = charTabController ??
        TabController(
          initialIndex: 0,
          length: totalCharacterTabs,
          vsync: this,
        );
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          buildCharacterTabController(context, charTabController),
          Positioned(
            top: screenPadding.top,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              enableFeedback: false,
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          TabsCharacterMenuWidget(characters, controller: charTabController),
          const InventoryNotificationWidget(key: Key('inventory_notification_widget')),
          Positioned(bottom: screenPadding.bottom, left: 0, right: 0, child: const SelectedItemsWidget()),
        ],
      ),
    );
  }

  Widget buildBackground(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
      colors: const [
        Color.fromARGB(255, 80, 90, 100),
        Color.fromARGB(255, 100, 100, 115),
        Color.fromARGB(255, 32, 32, 73),
      ],
      begin: const FractionalOffset(0, .5),
      end: const FractionalOffset(.5, 0),
    )));
  }

  Widget buildCharacterTabController(BuildContext context, TabController controller) {
    return TabBarView(controller: controller, children: getTabs());
  }

  List<Widget> getTabs() {
    List<Widget> characterTabs = characters.map((character) {
      return Container();
    }).toList();
    return characterTabs;
  }

  List<DestinyCharacterInfo> get characters {
    return profile.characters;
  }

  Widget buildLoading(BuildContext context) {
    return LoadingAnimWidget();
  }
}
