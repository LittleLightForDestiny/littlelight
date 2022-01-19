import 'package:flutter/material.dart';
import 'package:little_light/pages/presentation_node.screen.dart';
import 'package:little_light/pages/triumph_search.screen.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/services/profile/profile_component_groups.dart';
import 'package:little_light/services/user_settings/little_light_persistent_page.dart';
import 'package:little_light/services/user_settings/user_settings.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';

class OldTriumphsScreen extends PresentationNodeScreen {
  OldTriumphsScreen({presentationNodeHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeScreenState createState() => TriumphsScreenState();
}

const _page = LittleLightPersistentPage.Triumphs;

class TriumphsScreenState extends PresentationNodeScreenState<OldTriumphsScreen>
    with UserSettingsConsumer, AnalyticsConsumer, ProfileConsumer {
  @override
  void initState() {
    super.initState();
    profile.updateComponents = ProfileComponentGroups.triumphs;
    userSettings.startingPage = _page;
    analytics.registerPageOpen(_page);
  }

  @override
  Widget buildBody(BuildContext context) {
    var settings = DestinySettingsService();
    return PresentationNodeTabsWidget(
      presentationNodeHashes: [
        settings.triumphsRootNode,
        settings.sealsRootNode,
        511607103,
        settings.medalsRootNode,
        settings.loreRootNode,
        3215903653,
        1881970629
      ],
      depth: 0,
      itemBuilder: this.itemBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context), body: buildScaffoldBody(context));
  }

  buildAppBar(BuildContext context) {
    if (widget.depth == 0) {
      return AppBar(
        leading: IconButton(
          enableFeedback: false,
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: TranslatedTextWidget("Triumphs"),
        actions: <Widget>[
          IconButton(
            enableFeedback: false,
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TriumphSearchScreen(),
                ),
              );
            },
          )
        ],
      );
    }
    return AppBar(title: Text(definition?.displayProperties?.name ?? ""));
  }
}
