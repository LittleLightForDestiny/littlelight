import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/collections.screen.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

class PresentationNodeItemWidget extends StatelessWidget {
  final int hash;
  PresentationNodeItemWidget({Key key, this.hash}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DefinitionProviderWidget<DestinyPresentationNodeDefinition>(hash,
        (definition) {
      return RaisedButton(
        child: Text(definition.displayProperties.name),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollectionsScreen(
                    presentationNodeHash: hash,
                  ),
            ),
          );
        },
      );
    });
  }
}
