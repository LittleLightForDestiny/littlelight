import 'package:flutter/material.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

class BucketHeaderWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final int hash;
  BucketHeaderWidget({this.hash});
  @override
  BucketHeaderWidgetState createState() => new BucketHeaderWidgetState();
}

class BucketHeaderWidgetState extends State<BucketHeaderWidget>{
  Map<String,DestinyInventoryBucketDefinition> bucketDefinitions;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DestinyInventoryBucketDefinition def = widget.manifest.getBucketDefinition(widget.hash);
    return Container(
      color:Colors.red,
      padding:EdgeInsets.all(8),
      height: 20,
      child:Text(def.displayProperties.name)
    );
  }

}
