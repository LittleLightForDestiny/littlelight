//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/pages/settings/widgets/add_community_wishlist.form.dart';
import 'package:little_light/pages/settings/widgets/add_custom_wishlist.form.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

import 'providers/add_wishlists.provider.dart';

class AddWishlistPage extends StatefulWidget {
  AddWishlistPage();

  @override
  AddWishlistPageState createState() => AddWishlistPageState();
}

class AddWishlistPageState extends State<AddWishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddWishlistsProvider>().getWishlists();
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
                Container(padding: EdgeInsets.all(8), child: TranslatedTextWidget("Community")),
                Container(padding: EdgeInsets.all(8), child: TranslatedTextWidget("Custom")),
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

  Widget buildTitle(BuildContext context) => TranslatedTextWidget(
        "Add Wishlist",
        key: Key("title"),
      );
}
