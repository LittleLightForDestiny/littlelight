import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';

class SelectedPerkWidget extends AnimatedSize {
  SelectedPerkWidget(int hash, {BuildContext context, @required TickerProvider vsync})
      : super(
            duration: Duration(milliseconds: 300),
            vsync: vsync,
            child: hash == null
                ? Container()
                : DefinitionProviderWidget<DestinyInventoryItemDefinition>(hash,
                    (definition) {
                      double width = MediaQuery.of(context).size.width;
                    return SizedBox(
                        width: width,
                        child: Row(mainAxisSize: MainAxisSize.max, children: [
                      ManifestImageWidget<DestinyInventoryItemDefinition>(hash),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        Text(definition.displayProperties.name),
                        Text(
                          definition.displayProperties.description,
                          softWrap: true,
                        ),
                      ])
                    ]));
                  }));
}
