import 'package:bungie_api/models/destiny_presentation_node_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/utils/shimmer_helper.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';

class TriumphCategoryItemWidget extends StatefulWidget {
  final int nodeHash;

  TriumphCategoryItemWidget({Key key, this.nodeHash}) : super(key: key);
  @override
  _TriumphCategoryItemWidgetState createState() =>
      _TriumphCategoryItemWidgetState();
}

class _TriumphCategoryItemWidgetState extends State<TriumphCategoryItemWidget> with ManifestConsumer{
  DestinyPresentationNodeDefinition definition;

  @override
  void initState() {
    super.initState();
    getDefinition();
  }

  void getDefinition() async {
    definition = await manifest
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
        Image.asset(
          "assets/imgs/triumph_bg.png",
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
        QueuedNetworkImage(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          imageUrl: BungieApiService.url(definition.originalIcon),
        )
      ],
    );
  }
}
