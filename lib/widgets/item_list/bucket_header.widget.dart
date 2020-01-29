import 'package:flutter/material.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';

class BucketHeaderWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final int hash;
  final int itemCount;
  final bool isVault;
  BucketHeaderWidget({this.hash, this.itemCount = 0, this.isVault = false});
  @override
  BucketHeaderWidgetState createState() => new BucketHeaderWidgetState();
}

class BucketHeaderWidgetState extends State<BucketHeaderWidget> {
  Map<String, DestinyInventoryBucketDefinition> bucketDefinitions;
  DestinyInventoryBucketDefinition def;

  @override
  void initState() {
    super.initState();
    if (def == null) {
      fetchDefinition();
    }
  }

  fetchDefinition() async {
    def = await widget.manifest
        .getDefinition<DestinyInventoryBucketDefinition>(widget.hash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (def == null) {
      return Container();
    }
    return HeaderWidget(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text(
            def.displayProperties.name.toUpperCase(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          buildCount(context)
        ]));
  }

  buildCount(BuildContext context) {
    int bucketSize = def.itemCount;
    if (widget.hash == InventoryBucket.subclass) {
      bucketSize = 3;
    }
    if(widget.isVault){
      return ManifestText<DestinyInventoryBucketDefinition>(InventoryBucket.general, textExtractor: (def){
        return "${widget.itemCount}/${def.itemCount}";
      }, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),);
    }
    return Text(
      "${widget.itemCount}/$bucketSize",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
