//@dart=2.12

import 'package:bungie_api/user.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.yes_no.dialog.dart';

class LogoutDialogRoute extends DialogRoute<bool> {
  LogoutDialogRoute(BuildContext context, {required UserMembershipData account})
      : super(
          context: context,
          settings: RouteSettings(arguments: account),
          builder: (context) => LogoutDialog(),
        );
}

class LogoutDialog extends LittleLightYesNoDialog with AuthConsumer {
  LogoutDialog()
      : super(
            titleBuilder: (context) => TranslatedTextWidget("Logout"),
            bodyBuilder: (context) {
              final account = ModalRoute.of(context)?.settings.arguments as UserMembershipData;
              return TranslatedTextWidget("Are you sure you want to logout from the account {accountName}?",
                  replace: {"accountName": account.bungieNetUser?.uniqueName ?? ""});
            });

  @override
  void onSelect(BuildContext context, bool value) async {
    if (value != true) return;
    final account = ModalRoute.of(context)?.settings.arguments as UserMembershipData;
    final membershipID = account.bungieNetUser?.membershipId;
    if (membershipID == null) return;
    await auth.removeAccount(membershipID);
    Phoenix.rebirth(context);
  }
}
