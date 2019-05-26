import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class PerkListItem extends StatelessWidget {
  final DestinyInventoryItemDefinition definition;

  const PerkListItem({Key key, this.definition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.blueGrey.shade700, borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                child: QueuedNetworkImage(
                  imageUrl: BungieApiService.url(definition?.displayProperties?.icon),
                ),
              ),
              Container(width: 8,),
              Text(definition?.displayProperties?.name ?? "", style: TextStyle(fontWeight: FontWeight.bold),),
            ],
          ),
        ]));
  }
}
