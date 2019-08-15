import 'dart:async';
import 'package:bungie_api/models/destiny_vendor_category.dart';
import 'package:bungie_api/models/destiny_vendor_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/profile/vendors.service.dart';

import 'package:little_light/widgets/vendors/vendors_list_item.widget.dart';
import 'package:shimmer/shimmer.dart';

class VendorsListWidget extends StatefulWidget {
  final String characterId;
  final ProfileService profile = ProfileService();
  final ManifestService manifest = ManifestService();
  final VendorsService service = VendorsService();
  final List<int> ignoreVendorHashes = const [
    1976548992, //ikora
    997622907, //prismatic matrix
    2255782930, //master Rahool
  ];

  final List<int> vendorPriority = const [
    2190858386, //Xur
    863940356, //Spider
  ];

  VendorsListWidget({Key key, this.characterId}) : super(key: key);

  _VendorsListWidgetState createState() => _VendorsListWidgetState();
}

class _VendorsListWidgetState extends State<VendorsListWidget>
    with AutomaticKeepAliveClientMixin {
  List<DestinyVendorComponent> _vendors;

  @override
  void initState() {
    super.initState();
    getVendors();
  }

  Future<void> getVendors() async {
    var vendors = await widget.service.getVendors(widget.characterId);
    Map<int, List<DestinyVendorCategory>> _categories = {};
    for(var vendor in vendors.values){
      _categories[vendor.vendorHash] = await widget.service.getVendorCategories(widget.characterId, vendor.vendorHash);
    }
    _vendors = vendors.values.where((v) {
      if (!v.enabled) return false;
      if (widget.ignoreVendorHashes.contains(v.vendorHash)) return false;
      var categories = _categories[v.vendorHash];
    if ((categories?.length ?? 0) < 1) return false;
      return true;
    }).toList();
    var originalOrder = _vendors.map((v) => v.vendorHash).toList();
    _vendors.sort((vA, vB) {
      var priorityA = widget.vendorPriority.indexOf(vA.vendorHash);
      var priorityB = widget.vendorPriority.indexOf(vB.vendorHash);
      if (priorityA < 0) priorityA = 1000;
      if (priorityB < 0) priorityB = 1000;
      if (priorityA == priorityB) {
        priorityA = originalOrder.indexOf(vA.vendorHash);
        priorityB = originalOrder.indexOf(vB.vendorHash);
      }
      return priorityA.compareTo(priorityB);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_vendors == null) {
      return Center(
          child: Container(
              width: 96,
              child: Shimmer.fromColors(
                baseColor: Colors.blueGrey.shade300,
                highlightColor: Colors.white,
                child: Image.asset("assets/anim/loading.webp"),
              )));
    }
    return StaggeredGridView.countBuilder(
      crossAxisCount: 6,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemCount: _vendors?.length ?? 0,
      padding: EdgeInsets.all(4).copyWith(top: 0),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      staggeredTileBuilder: (index) {
        return StaggeredTile.fit(6);
      },
      itemBuilder: (context, index) {
        if (_vendors == null) return Container();
        var vendor = _vendors[index];
        return VendorsListItemWidget(
          characterId: widget.characterId,
          vendor: vendor,
          key: Key("progression_${vendor.vendorHash}"),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
