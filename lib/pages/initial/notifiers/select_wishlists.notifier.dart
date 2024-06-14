import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/littlelight_data/littlelight_data.bloc.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/littlelight/wishlists.consumer.dart';
import 'package:provider/provider.dart';

class SelectWishlistNotifier extends ChangeNotifier with WishlistsConsumer {
  final BuildContext context;
  final LittleLightDataBloc _littleLightDataBloc;

  WishlistFolder? _wishlistsIndexRoot;
  WishlistFolder? get wishlistsIndex => _wishlistsIndexRoot;
  WishlistFolder? _currentFolder;
  WishlistFolder? get currentFolder => _currentFolder ?? _wishlistsIndexRoot;
  bool get isRootFolder => wishlistsIndex == currentFolder;
  final Set<String> _selectedFiles = <String>{};

  SelectWishlistNotifier(this.context) : _littleLightDataBloc = context.read<LittleLightDataBloc>();

  void getFeaturedWishlists() async {
    final index = await _littleLightDataBloc.getFeaturedWishlists();
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
