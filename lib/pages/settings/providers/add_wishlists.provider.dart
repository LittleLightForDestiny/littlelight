//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/littlelight/littlelight_data.consumer.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';

class AddWishlistsProvider with ChangeNotifier, LittleLightDataConsumer, WishlistsConsumer {
  final BuildContext context;

  List<WishlistFile>? wishlists;
  WishlistFolder? _wishlistsIndexRoot;
  WishlistFolder? get wishlistsIndex => _wishlistsIndexRoot;
  WishlistFolder? _currentFolder;
  WishlistFolder? get currentFolder => _currentFolder ?? _wishlistsIndexRoot;
  bool get isRootFolder => wishlistsIndex == currentFolder;

  AddWishlistsProvider(this.context);

  void getWishlists() async {
    final index = await littleLightData.getFeaturedWishlists();
    index.files?.shuffle();
    index.folders?.shuffle();
    _wishlistsIndexRoot = index;
    wishlists = await wishlistsService.getWishlists();
    notifyListeners();
  }

  void goToFolder(WishlistFolder folder) {
    _currentFolder = folder;
    notifyListeners();
  }

  void goToRoot() {
    _currentFolder = _wishlistsIndexRoot;
    notifyListeners();
  }

  bool isAdded(WishlistFile wishlist) {
    return wishlists?.any((w) => w.url == wishlist.url) ?? false;
  }

  Future<void> addWishlist(WishlistFile wishlist) async {
    await wishlistsService.addWishlist(wishlist);
    wishlists = await wishlistsService.getWishlists();
    notifyListeners();
  }

  Future<void> removeWishlist(WishlistFile wishlist) async {
    await wishlistsService.removeWishlist(wishlist);
    wishlists = await wishlistsService.getWishlists();
    notifyListeners();
  }
}
