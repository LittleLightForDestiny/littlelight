import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class SealItemWidget extends StatefulWidget {
  final int nodeHash;

  SealItemWidget({Key key, this.nodeHash}) : super(key: key);
  @override
  _SealItemWidgetState createState() => _SealItemWidgetState();
}

class _SealItemWidgetState extends State<SealItemWidget> {
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    getDefinition();
  }

  void getDefinition() async {
    definition = await ManifestService()
        .getDefinition<DestinyPresentationNodeDefinition>(widget.nodeHash);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (definition == null) return ShimmerHelper.getDefaultShimmer(context);
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        QueuedNetworkImage(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          imageUrl: BungieApiService.url(definition.originalIcon),
        )
      ],
    );
  }
}
