import 'package:flutter/material.dart';
import 'package:bungie_api/models/destiny_inventory_bucket_definition.dart';
import 'package:little_light/services/bungie_api/enums/inventory_bucket_hash.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

class BucketHeaderWidget extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final int hash;
  final int itemCount;
  BucketHeaderWidget({this.hash, this.itemCount = 0});
  @override
  BucketHeaderWidgetState createState() => new BucketHeaderWidgetState();
}

class BucketHeaderWidgetState extends State<BucketHeaderWidget> {
  Map<String, DestinyInventoryBucketDefinition> bucketDefinitions;
  DestinyInventoryBucketDefinition def;

  @override
  void initState() {
    super.initState();
    if(def == null){
      fetchDefinition();
    }
  }

  fetchDefinition() async{
    def = await widget.manifest.getBucketDefinition(widget.hash);
    if(mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    if(def == null){
      return Container();
    }
    int bucketSize = def.itemCount;
    if(widget.hash == InventoryBucket.subclass){
      bucketSize = 3;
    }
    return Container(
        alignment: AlignmentDirectional.bottomCenter,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: BorderDirectional(bottom: BorderSide(color: Colors.white)),
          color: Colors.white.withOpacity(0.2),
        ),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                def.displayProperties.name.toUpperCase(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              Text(
                "${widget.itemCount}/$bucketSize",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              )
            ]));
  }
}
