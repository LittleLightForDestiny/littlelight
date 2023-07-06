import 'package:bungie_api/destiny2.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/destiny_character_info.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/core/blocs/vendors/vendors.bloc.dart';
import 'package:little_light/modules/vendors/pages/vendor_details/vendor_details.page_route.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/storage/storage.consumer.dart';
import 'package:provider/provider.dart';
import 'vendor_data.dart';

class VendorsHomeBloc extends ChangeNotifier with StorageConsumer {
  final BuildContext context;
  final ProfileBloc _profileBloc;
  final VendorsBloc _vendorsBloc;
  final ManifestService _manifestBloc;

  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  PageStorageBucket get pageStorageBucket => _pageStorageBucket;

  Map<String, bool> _hasCalledUpdate = {};
  Map<String, List<VendorData>> _characterVendorData = {};

  bool _reordering = false;
  bool get reordering => _reordering;

  VendorsHomeBloc(this.context)
      : _profileBloc = context.read<ProfileBloc>(),
        _vendorsBloc = context.read<VendorsBloc>(),
        _manifestBloc = context.read<ManifestService>() {
    _init();
  }

  _init() {
    final firstCharacter = characters?.first.characterId;
    if (firstCharacter != null) _loadDataFor(firstCharacter);
    _updateVendors();

    _vendorsBloc.addListener(_updateVendors);
  }

  @override
  void dispose() {
    super.dispose();
    _vendorsBloc.removeListener(_updateVendors);
  }

  void _updateVendors() async {
    final characterIds = _hasCalledUpdate.keys;
    for (final characterId in characterIds) {
      final data = await _processCharacterVendorData(characterId);
      if (data != null) _characterVendorData[characterId] = data;
    }
    notifyListeners();
  }

  Future<List<VendorData>?> _processCharacterVendorData(String characterId) async {
    final groups = _vendorsBloc.vendorGroupsFor(characterId);
    final order = await currentMembershipStorage.getVendorsOrder();
    if (groups == null) return null;
    final vendorsData = <VendorData>[];
    final vendorHashes = groups.fold<List<int>>([], (list, element) => list + (element.vendorHashes ?? []));
    final defs = await _manifestBloc.getDefinitions<DestinyVendorDefinition>(vendorHashes);
    for (final vendorHash in vendorHashes) {
      final def = defs[vendorHash];
      final vendor = _vendorsBloc.vendorFor(characterId, vendorHash);
      final categories = _vendorsBloc.categoriesFor(characterId, vendorHash)?.where((element) {
        final visible = _vendorsBloc.getCategoryVisibility(vendorHash, element);
        return visible;
      }).toList();
      final sales = _vendorsBloc.salesFor(characterId, vendorHash);
      final isVisible = def?.visible ?? false;
      if (vendor == null || !isVisible) continue;
      vendorsData.add(VendorData(vendor, categories, sales));
    }
    vendorsData.sort((a, b) => _sortVendors(a, b, order ?? [], vendorHashes));
    return vendorsData;
  }

  List<DestinyCharacterInfo>? get characters {
    return _profileBloc.characters;
  }

  List<VendorData>? vendorsFor(String characterId) {
    final calledUpdate = _hasCalledUpdate[characterId] ?? false;
    if (!calledUpdate) _loadDataFor(characterId);
    return _characterVendorData[characterId];
  }

  void _loadDataFor(String characterId) async {
    _hasCalledUpdate[characterId] = true;
    await _vendorsBloc.refresh(characterId);
  }

  void toggleReordering() {
    this._reordering = !this._reordering;
    notifyListeners();
  }

  void reorderVendors(String characterId, int oldIndex, int newIndex) {
    final newOrder = _characterVendorData[characterId]?.map((v) => v.vendor.vendorHash).toList();
    if (newOrder == null) return;
    final removed = newOrder.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex = newIndex - 1;
    newOrder.insert(newIndex, removed);

    for (final data in _characterVendorData.values) {
      data.sort((a, b) => _sortVendors(a, b, newOrder, []));
    }
    currentMembershipStorage.saveVendorsOrder(newOrder.whereType<int>().toList());
    notifyListeners();
  }

  int _sortVendors(a, b, List<int?> order, List<int?> oldOrder) {
    final hashA = a.vendor.vendorHash;
    final hashB = b.vendor.vendorHash;
    int indexA = order.indexOf(hashA);
    int indexB = order.indexOf(hashB);
    if (indexA < 0) indexA = oldOrder.indexOf(hashA);
    if (indexB < 0) indexB = oldOrder.indexOf(hashB);
    return indexA.compareTo(indexB);
  }

  void openVendorDetails(String characterId, VendorData vendor) {
    final vendorHash = vendor.vendor.vendorHash;
    if (vendorHash == null) return;
    Navigator.of(context).push(VendorDetailsPageRoute(characterId, vendorHash));
  }
}
