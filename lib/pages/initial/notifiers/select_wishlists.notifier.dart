import 'package:flutter/material.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';

class SelectWishlistNotifier with ChangeNotifier, LittleLightDataConsumer, WishlistsConsumer {
  final BuildContext context;

  WishlistFolder? _wishlistsIndexRoot;
  WishlistFolder? get wishlistsIndex => _wishlistsIndexRoot;
  WishlistFolder? _currentFolder;
  WishlistFolder? get currentFolder => _currentFolder ?? _wishlistsIndexRoot;
  bool get isRootFolder => wishlistsIndex == currentFolder;
  Set<String> _selectedFiles = Set<String>();

  SelectWishlistNotifier(this.context);

  void getFeaturedWishlists() async {
    final index = await littleLightData.getFeaturedWishlists();
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

  _getSelectedWishlists([WishlistFolder? folder]) {
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
    await wishlistsService.setWishlists(wishlists);
  }
}
