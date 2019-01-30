import 'package:flutter/material.dart';
import 'package:little_light/screens/base/presentation_node_base.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/utils/destiny_data.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class CollectionsScreen extends PresentationNodeBaseScreen {
  CollectionsScreen(
      {presentationNodeHash = DestinyData.collectionsRootHash, depth = 0})
      : super(presentationNodeHash: presentationNodeHash, depth: depth);

  @override
  PresentationNodeBaseScreenState createState() => new CollectionsScreenState();
}

class CollectionsScreenState extends PresentationNodeBaseScreenState {


  @override
    void initState() {
      SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.collections);
      AuthService auth = AuthService();
      if(auth.isLogged){
        ProfileService().fetchProfileData(components:ProfileComponentGroups.collections);
      }
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
          title: TranslatedTextWidget("Collections"));
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
        builder: (context) => CollectionsScreen(
              presentationNodeHash: hash,
              depth: depth + 1,
            ),
      ),
    );
  }
}
