import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/mixins/tab_grid/tab_grid.mixin.dart';
import 'package:little_light/widgets/triumphs/triumph_category_item.widget.dart';

class TriumphCategoriesGridWidget extends StatefulWidget {
  final int nodeHash;
  final int columns;
  final int rows;
  final double itemAspectRatio;

  TriumphCategoriesGridWidget({Key key, this.nodeHash, this.rows = 2, this.columns = 3, this.itemAspectRatio = 1})
      : super(key: key);
  @override
  _TriumphCategoriesGridWidgetState createState() => _TriumphCategoriesGridWidgetState();
}

class _TriumphCategoriesGridWidgetState extends State<TriumphCategoriesGridWidget>
    with
        TickerProviderStateMixin,
        TabGridMixin<TriumphCategoriesGridWidget, DestinyPresentationNodeChildEntry>,
        ManifestConsumer {
  DestinyPresentationNodeDefinition definition;
  TabController _controller;

  @override
  void initState() {
    super.initState();
    getDefinitions();
  }

  void getDefinitions() async {
    definition = await manifest.getDefinition<DestinyPresentationNodeDefinition>(widget.nodeHash);
    _controller = TabController(initialIndex: 0, length: pageCount, vsync: this);
    _controller.addListener(() {
      setState(() {});
    });
    setState(() {});
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<DestinyPresentationNodeChildEntry> get childNodes => definition?.children?.presentationNodes;

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    return Column(
      children: [header(context), Container(padding: EdgeInsets.symmetric(vertical: 8), child: super.build(context))],
    );
  }

  Widget header(BuildContext context) => HeaderWidget(
        child: Text(definition.displayProperties.name.toUpperCase()),
      );

  int get pageCount => (childNodes.length / tilesPerPage).ceil();
  int get tilesPerPage => widget.rows * widget.columns;

  @override
  Widget buildItem(BuildContext context, DestinyPresentationNodeChildEntry child) {
    return TriumphCategoryItemWidget(nodeHash: child.presentationNodeHash);
  }

  @override
  int get columnCount => widget.columns;

  @override
  double get itemAspectRatio => widget.itemAspectRatio;

  @override
  int get rowCount => widget.rows;
}
