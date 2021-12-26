//@dart=2.12
import 'dart:math';

import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/notifiers/select_membership.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

class SelectWishlistsSubPage extends StatefulWidget {
  SelectWishlistsSubPage();

  @override
  SelectWishlistsSubPageState createState() => new SelectWishlistsSubPageState();
}

class SelectWishlistsSubPageState extends SubpageBaseState<SelectWishlistsSubPage> with AuthConsumer {
  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  void loadAccounts() async {
    context.read<SelectMembershipNotifier>().loadAccounts();
  }

  @override
  Widget buildTitle(BuildContext context) => TranslatedTextWidget(
        "Select Wishlists",
        key: Key("title"),
      );

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              constraints: BoxConstraints(maxHeight: max(240, MediaQuery.of(context).size.height - 300)),
              child: SingleChildScrollView(
                  child: Container(
                      child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [],
              )))),
          ElevatedButton(
            onPressed: () {
              auth.openBungieLogin(true);
            },
            child: TranslatedTextWidget(
              "Add custom Wishlist",
            ),
          )
        ],
      ));
}
