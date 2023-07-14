import 'package:bungie_api/destiny2.dart';

class VendorData {
  final DestinyVendorComponent vendor;
  final List<DestinyVendorCategory>? categories;
  final Map<String, DestinyVendorSaleItemComponent>? sales;

  VendorData(this.vendor, this.categories, this.sales);
}
