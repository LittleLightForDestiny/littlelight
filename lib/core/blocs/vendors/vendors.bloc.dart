import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/user_settings/user_settings.bloc.dart';
import 'package:little_light/core/blocs/vendors/vendor_item_info.dart';
import 'package:little_light/services/bungie_api/bungie_api.consumer.dart';
import 'package:little_light/services/storage/storage.consumer.dart';
import 'package:provider/provider.dart';

const _vendorComponents = [
  DestinyComponentType.ItemInstances,
  DestinyComponentType.ItemSockets,
  DestinyComponentType.ItemReusablePlugs,
  DestinyComponentType.Vendors,
  DestinyComponentType.VendorCategories,
  DestinyComponentType.VendorSales,
  DestinyComponentType.ItemStats,
];

class VendorsBloc extends ChangeNotifier with BungieApiConsumer, StorageConsumer {
  @protected
  final BuildContext context;
  final UserSettingsBloc _userSettingsBloc;

  bool _hasStartedLoading = false;
  Map<String, DestinyVendorsResponse> _characterVendorResponses = {};

  VendorsBloc(BuildContext this.context) : _userSettingsBloc = context.read<UserSettingsBloc>();

  void _loadVendorsFor(String characterId) async {
    if (!_hasStartedLoading) {
      final vendors = await currentMembershipStorage.getCachedVendors();
      if (vendors != null) {
        _characterVendorResponses = vendors;
      }
    }

    if (_characterVendorResponses[characterId] != null) {
      notifyListeners();
      return;
    }
    await refresh(characterId);
  }

  DestinyVendorsResponse? _getVendorsResponseFor(String characterId) {
    if (_characterVendorResponses[characterId] != null) return _characterVendorResponses[characterId];
    _loadVendorsFor(characterId);
    return null;
  }

  List<DestinyVendorGroup>? vendorGroupsFor(String characterId) {
    final vendorsResponse = _getVendorsResponseFor(characterId);
    return vendorsResponse?.vendorGroups?.data?.groups;
  }

  Map<String, DestinyVendorComponent>? vendorsFor(String characterId) {
    final vendorsResponse = _getVendorsResponseFor(characterId);
    return vendorsResponse?.vendors?.data;
  }

  DestinyVendorComponent? vendorFor(String characterId, int vendorHash) {
    final vendorsResponse = _getVendorsResponseFor(characterId);
    return vendorsResponse?.vendors?.data?["$vendorHash"];
  }

  Future<void> refresh(String characterId) async {
    final response = await bungieAPI.getVendors(_vendorComponents, characterId);
    if (response == null) return;
    this._characterVendorResponses[characterId] = response;
    currentMembershipStorage.saveCachedVendors(this._characterVendorResponses);
    notifyListeners();
  }

  List<DestinyVendorCategory>? categoriesFor(String characterId, int? vendorHash) {
    final vendorsResponse = _getVendorsResponseFor(characterId);
    return vendorsResponse?.categories?.data?["$vendorHash"]?.categories;
  }

  Map<String, VendorItemInfo>? itemsFor(String characterId, int? vendorHash) {
    final vendorsResponse = _getVendorsResponseFor(characterId);
    final components = vendorsResponse?.itemComponents?["$vendorHash"];
    return vendorsResponse?.sales?.data?["$vendorHash"]?.saleItems?.map(
      (key, sale) => MapEntry(
        key,
        VendorItemInfo(
          sale,
          instanceInfo: components?.instances?.data?[key],
          characterId: characterId,
          plugObjectives: components?.plugObjectives?.data?[key]?.objectivesPerPlug,
          reusablePlugs: components?.reusablePlugs?.data?[key]?.plugs,
          sockets: components?.sockets?.data?[key]?.sockets,
          stats: components?.stats?.data?[key]?.stats,
        ),
      ),
    );
  }

  Map<String, DestinyVendorSaleItemComponent>? salesFor(String characterId, int? vendorHash) {
    final vendorsResponse = _getVendorsResponseFor(characterId);
    return vendorsResponse?.sales?.data?["$vendorHash"]?.saleItems;
  }

  String getCategoryVisibilityKey(int vendorHash, DestinyVendorCategory category) {
    return 'vendor $vendorHash category ${category.displayCategoryIndex}';
  }

  bool getCategoryVisibility(int vendorHash, DestinyVendorCategory category) {
    return _userSettingsBloc.getSectionVisibleState(getCategoryVisibilityKey(vendorHash, category), defaultValue: true);
  }

  void setCategoryVisibility(int vendorHash, DestinyVendorCategory category, bool value) {
    _userSettingsBloc.setSectionVisibleState(getCategoryVisibilityKey(vendorHash, category), value);
    notifyListeners();
  }
}
