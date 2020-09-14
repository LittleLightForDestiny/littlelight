import 'package:flutter/material.dart';
import 'package:little_light/screens/presentation_node.screen.dart';
import 'package:little_light/screens/triumph_search.screen.dart';
import 'package:little_light/services/profile/destiny_settings.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';

class TriumphsScreen extends PresentationNodeScreen {
  TriumphsScreen({presentationNodeHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeScreenState createState() => TriumphsScreenState();
}

class TriumphsScreenState extends PresentationNodeScreenState<TriumphsScreen> {
  @override
  void initState() {
    super.initState();
    ProfileService().updateComponents = ProfileComponentGroups.triumphs;
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.triumphs);
  }

  @override
  Widget buildBody(BuildContext context) {
    var settings = DestinySettingsService();
    return PresentationNodeTabsWidget(
      presentationNodeHashes: [
        settings.triumphsRootNode,
        settings.sealsRootNode,
        settings.statsRootNode
      ],
      depth: 0,
      itemBuilder: this.itemBuilder,
      tileBuilder: this.tileBuilder,
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
