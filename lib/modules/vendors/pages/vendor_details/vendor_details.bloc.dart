import 'package:bungie_api/src/models/destiny_vendor_category.dart';
import 'package:bungie_api/src/models/destiny_vendor_sale_item_component.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/core/blocs/vendors/vendors.bloc.dart';
import 'package:provider/provider.dart';

class VendorDetailsBloc extends ChangeNotifier {
  final BuildContext context;
  final String characterId;
  final int vendorHash;

  final VendorsBloc _vendorsBloc;

  Map<String, DestinyVendorSaleItemComponent>? _sales;
  Map<String, DestinyVendorSaleItemComponent>? get sales => _sales;

  Map<String, VendorItemInfo>? _items;
  Map<String, VendorItemInfo>? get items => _items;

  List<DestinyVendorCategory>? _categories;
  List<DestinyVendorCategory>? get categories => _categories;

  VendorDetailsBloc(this.context, this.characterId, this.vendorHash) : _vendorsBloc = context.read<VendorsBloc>() {
    _init();
  }

  _init() {
    final categories = _vendorsBloc.categoriesFor(characterId, vendorHash);
    final sales = _vendorsBloc.salesFor(characterId, vendorHash);
    final items = _vendorsBloc.itemsFor(characterId, vendorHash);
    this._categories = categories;
    this._sales = sales;
    this._items = items;
    notifyListeners();
  }

  bool isCategoryVisible(DestinyVendorCategory category) {
    return _vendorsBloc.getCategoryVisibility(vendorHash, category);
  }

  void changeCategoryVisibility(DestinyVendorCategory category, bool value) {
    _vendorsBloc.setCategoryVisibility(vendorHash, category, value);
    notifyListeners();
  }
}
