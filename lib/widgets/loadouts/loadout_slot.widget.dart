import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class LoadoutSlotWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final ProfileService profile = new ProfileService();
  final AuthService auth = new AuthService();
  final int bucketHash;
  LoadoutSlotWidget({Key key, this.bucketHash}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoadoutSlotWidgetState();
  }
}

class LoadoutSlotWidgetState extends State<LoadoutSlotWidget> {
  DestinyInventoryBucketDefinition bucketDefinition;

  @override
  void initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    bucketDefinition = await widget.manifest
        .getDefinition<DestinyInventoryBucketDefinition>(widget.bucketHash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bucketDefinition == null) {
      return AspectRatio(aspectRatio: .3);
    }
    return Column(children: [
      HeaderWidget(
          child: Text(bucketDefinition.displayProperties.name.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold))),
      buildEquippedBlock(context),
      Container(height: 8)
    ]);
  }

  Widget buildEquippedBlock(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(4),
        color: Colors.blueGrey.shade800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildBlockTitle(
                context,
                TranslatedTextWidget(
                  "Equip",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  uppercase: true,
                )),
            buildItemIcons(context)
          ],
        ));
  }

  Widget buildBlockTitle(BuildContext context, Widget textWidget) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey.shade900,
      child: textWidget,
    );
  }

  Widget buildTransferBlock(BuildContext context) {}

  buildItemIcons(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical:4),
        child: Wrap(
          children: <Widget>[
            buildEmptyItemIcon(context),
          ],
        ));
  }

  buildEmptyItemIcon(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 1 / 7,
        child: ManifestImageWidget<DestinyInventoryItemDefinition>(1835369552));
  }
}
