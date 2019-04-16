import 'package:flutter/material.dart';
import 'package:little_light/screens/base/presentation_node_base.screen.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/presentation_nodes/presentation_node_tabs.widget.dart';

class TriumphsScreen extends PresentationNodeBaseScreen {
  TriumphsScreen({presentationNodeHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeBaseScreenState createState() => new TriumphsScreenState();
}

class TriumphsScreenState extends PresentationNodeBaseScreenState {
  @override
  void initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.triumphs);
    ProfileService()
        .fetchProfileData(components: ProfileComponentGroups.triumphs);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: buildScaffoldBody(context, widget.depth));
  }

  Widget buildScaffoldBody(BuildContext context, int depth) {
    return Stack(children: [
      buildBody(context, hash: widget.presentationNodeHash, depth: depth),
      InventoryNotificationWidget(
        key: Key('inventory_notification_widget'),
        barHeight: 0,
      ),
    ]);
  }

  @override
  Widget tabBuilder(int presentationNodeHash, int depth) {
    if (presentationNodeHash == null) {
      return PresentationNodeTabsWidget(
        presentationNodeHashes: [
          DestinyData.triumphsRootHash,
          DestinyData.sealsRootHash
        ],
        depth: 0,
        bodyBuilder: (int presentationNodeHash, depth) {
          return buildBody(context, hash: presentationNodeHash, depth: 1);
        },
      );
    }
    return super.tabBuilder(presentationNodeHash, depth);
  }

  buildAppBar(BuildContext context) {
    if (widget.depth == 0) {
      return AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          title: TranslatedTextWidget("Triumphs"));
    }
    return AppBar(title: Text(definition?.displayProperties?.name ?? ""));
  }

  @override
  void onPresentationNodePressed(int hash, int depth) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TriumphsScreen(
              presentationNodeHash: hash,
              depth: depth + 1,
            ),
      ),
    );
  }
}
