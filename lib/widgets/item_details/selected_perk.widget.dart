import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class SelectedPerkWidget extends StatelessWidget {
  final int hash;
  SelectedPerkWidget(this.hash, {Key key}):super(key:key);

  @override
  Widget build(BuildContext context) {
    if(hash == null) return Container();
    return DefinitionProviderWidget<DestinyInventoryItemDefinition>(hash,
        (definition) {
      double width = MediaQuery.of(context).size.width;
      return Container(
          margin: EdgeInsets.only(left:8, right:8, bottom:8),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          width: width,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
                decoration: BoxDecoration(
            color: Colors.blueGrey.shade700,
            borderRadius: BorderRadius.circular(8),
          ),  
                padding: EdgeInsets.all(8),
                
                child: Text(
                  definition.displayProperties.name.toUpperCase(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            Row(mainAxisSize: MainAxisSize.max, children: [
              Container(
                width: 72,
                child:
                    ManifestImageWidget<DestinyInventoryItemDefinition>(hash),
              ),
              Expanded(
                  child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  definition.displayProperties.description,
                  softWrap: true,
                ),
              ))
            ])
          ]));
    });
  }
}
