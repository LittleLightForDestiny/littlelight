import 'package:flutter/material.dart';
import 'package:little_light/screens/base/presentation_node_base.screen.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class TriumphsScreen extends PresentationNodeBaseScreen {
  TriumphsScreen(
      {presentationNodeHash = DestinyData.triumphsRootHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeBaseScreenState createState() => new TriumphsScreenState();
}

class TriumphsScreenState extends PresentationNodeBaseScreenState {
  @override
    void initState() {
      SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.triumphs);
      ProfileService().fetchProfileData(components:ProfileComponentGroups.triumphs);
      super.initState();
    }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    return Scaffold(
        appBar: buildAppBar(context),
        body: buildBody(context, widget.presentationNodeHash, widget.depth < 2 ? widget.depth : widget.depth + 1));
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
    return AppBar(
      title:Text(definition.displayProperties.name)
    );
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
