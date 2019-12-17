import 'package:bungie_api/models/destiny_record_definition.dart';

import 'package:flutter/material.dart';
import 'package:little_light/screens/definition_search.screen.dart';

import 'package:little_light/widgets/presentation_nodes/record_item.widget.dart';

class TriumphSearchScreen extends DefinitionSearchScreen {
  TriumphSearchScreen({Key key}) : super(key: key);

  @override
  TriumphSearchScreenState createState() => new TriumphSearchScreenState();
}

class TriumphSearchScreenState extends DefinitionSearchScreenState<
    DefinitionSearchScreen, DestinyRecordDefinition> {
  @override
  initState() {
    super.initState();
  }

  Widget itemBuilder(BuildContext context, int index) {
    var item = items[index];
    return RecordItemWidget(
      key: Key("${item.hash}"),
      hash: item.hash,
    );
  }
}
