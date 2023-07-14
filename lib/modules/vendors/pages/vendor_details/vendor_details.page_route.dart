import 'package:flutter/material.dart';
import 'package:little_light/modules/vendors/pages/vendor_details/vendor_details.page.dart';

class VendorDetailsPageRoute extends MaterialPageRoute {
  VendorDetailsPageRoute(String characterId, int vendorHash)
      : super(
            builder: (context) => VendorDetailsPage(
                  characterId,
                  vendorHash,
                ));
}
