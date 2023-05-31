import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/modules/item_details/pages/vendor_item_details/vendor_item_details.page.dart';

class VendorItemDetailsPageRoute extends MaterialPageRoute {
  final VendorItemInfo item;

  VendorItemDetailsPageRoute(this.item)
      : super(builder: (context) {
          return VendorItemDetailsPage(item);
        });
}
