//@dart=2.12
import 'package:get_it/get_it.dart';

import 'wishlists.service.dart';

WishlistsService getInjectedWishlistsService() => GetIt.I<WishlistsService>();

mixin WishlistsConsumer {
  WishlistsService get wishlistsService => getInjectedWishlistsService();
}
