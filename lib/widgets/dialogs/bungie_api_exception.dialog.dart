import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/bungie_api.exception.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/storage/storage.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

class BungieApiExceptionDialogRoute extends DialogRoute<void> {
  BungieApiExceptionDialogRoute(BuildContext context, {required BungieApiException error})
      : super(
            context: context,
            builder: (context) => BungieApiExceptionDialog(),
            settings: RouteSettings(arguments: error),
            barrierDismissible: false);
}

extension on BuildContext {
  BungieApiException? get errorArgument => ModalRoute.of(this)?.settings.arguments as BungieApiException;
}

class BungieApiExceptionDialog extends LittleLightBaseDialog with AuthConsumer, StorageConsumer {
  BungieApiExceptionDialog() : super();

  @override
  Widget? buildTitle(BuildContext context) {
    final error = context.errorArgument;
    return TranslatedTextWidget(error?.errorStatus ?? "error");
  }

  @override
  Widget? buildBody(BuildContext context) {
    final error = context.errorArgument;
    if (error == null) return Container();
    return Container(child: TranslatedTextWidget(error.message));
  }

  @override
  Widget? buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          child: Text("Restart app".translate(context).toUpperCase()),
          onPressed: () async {
            Phoenix.rebirth(context);
          },
        ),
        TextButton(
          child: Text("Reauthenticate with Bungie".translate(context).toUpperCase()),
          onPressed: () async {
            auth.openBungieLogin(true);
          },
        ),
        TextButton(
          child: TranslatedTextWidget(
            "Clear app data",
            uppercase: true,
            style: TextStyle(color: LittleLightTheme.of(context).errorLayers),
          ),
          onPressed: () async {
            await globalStorage.purge();
            Phoenix.rebirth(context);
          },
        ),
        TextButton(
          child: Text("Exit app".translate(context).toUpperCase()),
          onPressed: () async {
            exit(0);
          },
        ),
      ],
    );
  }
}
