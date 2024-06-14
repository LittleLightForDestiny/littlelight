import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:provider/provider.dart';

class AddWishlistsBloc extends ChangeNotifier with WishlistsConsumer {
  final BuildContext context;
  final LittleLightDataBloc _littleLightDataBloc;

  List<WishlistFile>? wishlists;
  WishlistFolder? _wishlistsIndexRoot;
  WishlistFolder? get wishlistsIndex => _wishlistsIndexRoot;
  WishlistFolder? _currentFolder;
  WishlistFolder? get currentFolder => _currentFolder ?? _wishlistsIndexRoot;
  bool get isRootFolder => wishlistsIndex == currentFolder;

  AddWishlistsBloc(this.context) : _littleLightDataBloc = context.read<LittleLightDataBloc>();

  void getWishlists() async {
    final index = await _littleLightDataBloc.getFeaturedWishlists();
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
