import 'package:bungie_api/models/destiny_record_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/item_details/item_lore.widget.dart';

class RecordDetailScreen extends StatefulWidget {
  final DestinyRecordDefinition definition;

  RecordDetailScreen(this.definition, {Key key}) : super(key: key);

  @override
  State<RecordDetailScreen> createState() {
    return RecordDetailScreenState();
  }
}

class RecordDetailScreenState extends State<RecordDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.definition.displayProperties.name),
        ),
        body: CustomScrollView(slivers: [
          // ItemCoverWidget(item, definition, instanceInfo),
          SliverList(
            delegate: SliverChildListDelegate([
              ItemLoreWidget(widget.definition.loreHash),
              Container(height: 500)
            ]),
          ),
        ]));
  }
}
