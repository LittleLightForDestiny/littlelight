//@dart=2.12
import 'package:get_it/get_it.dart';
import 'package:little_light/models/wishlist_index.dart';
import 'package:little_light/services/storage/storage.consumer.dart';

setupWishlistsService() {
  GetIt.I.registerSingleton<WishlistsService>(WishlistsService._internal());
}

class WishlistsService with StorageConsumer {
  Future<List<WishlistFile>?> getWishlists() => globalStorage.getWishlists();
  Future<void> setWishlists(List<WishlistFile> wishlists) async => await globalStorage.setWishlists(wishlists);
  WishlistsService._internal();
}
