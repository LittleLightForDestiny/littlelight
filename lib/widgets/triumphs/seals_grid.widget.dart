import 'package:bungie_api/models/destiny_presentation_node_child_entry.dart';
import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/mixins/tab_grid/tab_grid.mixin.dart';
import 'package:little_light/widgets/triumphs/seal_item.widget.dart';

class SealsGridWidget extends StatefulWidget {
  final int nodeHash;
  final int columns;
  final int rows;
  final double itemAspectRatio;

  SealsGridWidget(
      {Key key,
      this.nodeHash,
      this.rows = 1,
      this.columns = 4,
      this.itemAspectRatio = 1})
      : super(key: key);
  @override
  _SealsGridWidgetState createState() => _SealsGridWidgetState();
}

class _SealsGridWidgetState extends State<SealsGridWidget>
    with
        TickerProviderStateMixin,
        TabGridMixin<SealsGridWidget, DestinyPresentationNodeChildEntry>, ManifestConsumer {
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    getDefinitions();
  }

  void getDefinitions() async {
    definition = await manifest
        .getDefinition<DestinyPresentationNodeDefinition>(widget.nodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return Container();
    return Column(
      children: [
        header(context),
        Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: super.build(context))
      ],
    );
  }

  Widget header(BuildContext context) => HeaderWidget(
        child: Text(definition.displayProperties.name.toUpperCase()),
      );

  @override
  Widget buildItem(
      BuildContext context, DestinyPresentationNodeChildEntry child) {
    return SealItemWidget(nodeHash: child.presentationNodeHash);
  }

  @override
  List<DestinyPresentationNodeChildEntry> get childNodes =>
      definition?.children?.presentationNodes;

  @override
  int get columnCount => widget.columns;

  @override
  double get itemAspectRatio => widget.itemAspectRatio;

  @override
  int get rowCount => widget.rows;
}
