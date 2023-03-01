import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/modules/settings/widgets/add_community_wishlist.form.dart';
import 'package:little_light/modules/settings/widgets/add_custom_wishlist.form.dart';
import 'package:provider/provider.dart';

import 'add_wishlists.bloc.dart';

class AddWishlistPage extends StatefulWidget {
  const AddWishlistPage();

  @override
  AddWishlistPageState createState() => AddWishlistPageState();
}

class AddWishlistPageState extends State<AddWishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddWishlistsBloc>().getWishlists();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: buildTitle(context),
            bottom: TabBar(
              tabs: [
                Container(
                    padding: const EdgeInsets.all(8),
                    child: Text("Community".translate(context))),
                Container(
                    padding: const EdgeInsets.all(8),
                    child: Text("Custom".translate(context))),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              AddCommunityWishlistForm(),
              AddCustomWishlistForm(),
            ],
          ),
        ));
  }

  Widget buildTitle(BuildContext context) => Text(
        "Add Wishlist".translate(context),
        key: const Key("title"),
      );
}
