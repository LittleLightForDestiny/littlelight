import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'add_wishlist.page.dart';
import 'add_wishlists.bloc.dart';

class AddWishlistPageRoute extends MaterialPageRoute {
  AddWishlistPageRoute()
      : super(
          builder: (context) => ChangeNotifierProvider(
            create: (BuildContext context) => AddWishlistsBloc(context),
            child: AddWishlistPage(),
          ),
        );
}
