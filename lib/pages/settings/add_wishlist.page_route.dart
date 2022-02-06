//@dart=2.12
import 'package:flutter/material.dart';
import 'package:little_light/pages/settings/providers/add_wishlists.provider.dart';
import 'package:little_light/pages/settings/add_wishlist.page.dart';
import 'package:provider/provider.dart';

class AddWishlistPageRoute extends MaterialPageRoute {
  AddWishlistPageRoute()
      : super(
          builder: (context) => ChangeNotifierProvider(
            create: (BuildContext context) => AddWishlistsProvider(context),
            child: AddWishlistPage(),
          ),
        );
}
