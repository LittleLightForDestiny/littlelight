import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/littlelight/wishlists.service.dart';

class SelectWishlistBloc extends ChangeNotifier {
  final WishlistsService _wishlistsService;
  final LittleLightDataBloc _littleLightData;

  WishlistFolder? _wishlistsIndexRoot;
  WishlistFolder? get wishlistsIndex => _wishlistsIndexRoot;
  WishlistFolder? _currentFolder;
  WishlistFolder? get currentFolder => _currentFolder ?? _wishlistsIndexRoot;
  bool get isRootFolder => wishlistsIndex == currentFolder;
  final Set<String> _selectedFiles = <String>{};

  SelectWishlistBloc({
    required LittleLightDataBloc littleLightData,
    required WishlistsService wishlistsService,
  }) : this._littleLightData = littleLightData,
       this._wishlistsService = wishlistsService;

  void getFeaturedWishlists() async {
    final index = await _littleLightData.getFeaturedWishlists();
    index.files?.shuffle();
    index.folders?.shuffle();
    _wishlistsIndexRoot = index;
    notifyListeners();
  }

  bool isChecked(WishlistFile file) {
    return _selectedFiles.contains(file.url);
  }

  int get selectedCount {
    return _selectedFiles.length;
  }

  void goToFolder(WishlistFolder folder) {
    _currentFolder = folder;
    notifyListeners();
  }

  void goToRoot() {
    _currentFolder = _wishlistsIndexRoot;
    notifyListeners();
  }

  void toggleChecked(WishlistFile file) {
    if (isChecked(file)) {
      _selectedFiles.remove(file.url);
    } else {
      _selectedFiles.add(file.url!);
    }
    notifyListeners();
  }

  List<WishlistFile> _getSelectedWishlists([WishlistFolder? folder]) {
    folder ??= _wishlistsIndexRoot;
    final wishlists = <WishlistFile>[];
    final folders = folder?.folders ?? [];
    for (final f in folders) {
      wishlists.addAll(_getSelectedWishlists(f));
    }
    final files = folder?.files ?? [];
    wishlists.addAll(files.where((element) => _selectedFiles.contains(element.url)));
    return wishlists;
  }

  Future<void> saveSelections() async {
    final wishlists = _getSelectedWishlists();
    await _wishlistsService.setWishlists(wishlists);
  }
}
