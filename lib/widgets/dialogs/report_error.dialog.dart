//@dart=2.12


import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/services/analytics/analytics.consumer.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/dialogs/littlelight.base.dialog.dart';

class ReportErrorDialogRoute extends DialogRoute<void> {
  ReportErrorDialogRoute(BuildContext context, {required FlutterErrorDetails error})
      : super(
            context: context,
            builder: (context) => ReportErrorDialog(),
            settings: RouteSettings(arguments: error),
            barrierDismissible: false);
}

extension on BuildContext {
  FlutterErrorDetails? get errorArgument => ModalRoute.of(this)?.settings.arguments as FlutterErrorDetails;
}

class ReportErrorDialog extends LittleLightBaseDialog with AuthConsumer, AnalyticsConsumer, LanguageConsumer {
  ReportErrorDialog() : super();

  @override
  Widget? buildTitle(BuildContext context) {
    return TranslatedTextWidget("Send error report");
  }

  @override
  Widget? buildBody(BuildContext context) {
    final error = context.errorArgument;
    if (error == null) return Container();
    return Container(
        child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
      TranslatedTextWidget("This will be the info that will be sent along with the error report:"),
      Container(height: 8,),
      FutureBuilder<Map<String, String>?>(
        future: getData(),
        builder: (context, data){
          String text = "";
          final fields = data.data;
          if(fields!=null){
            for(final key in fields.keys){
              final value = fields[key];
              if(value != null){
                text += "$key : $value \n";
              }
            }
          }
          final cleanStack = error.stack.toString().split('\n').where((s) => s.contains('package:little_light')).join('\n');
          text += "exception:\n${error.exceptionAsString()}\n";
          text += "stackTrace:\n$cleanStack\n";
          return Container(
            decoration: BoxDecoration(color: LittleLightTheme.of(context).surfaceLayers.layer2, borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(8),
            child: Text(text, style: TextStyle(fontSize: 11),),);
        })
    ])));
  }

  @override
  Widget? buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          child: TranslatedTextWidget("Cancel", uppercase: true),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: TranslatedTextWidget("Send report", uppercase: true),
          onPressed: () async {
            final error = context.errorArgument;
            if(error == null) return;
            final data = await getData();
            analytics.registerUserFeedback(error, data?["playerID"] ?? "", data ?? {});
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<Map<String, String>?> getData() async {
    final membership = await auth.getMembership();
    final Map<String, String> data = {
      "playerID": membership?.bungieGlobalDisplayName ?? "",
      "accountID": auth.currentAccountID ?? "",
      "membershipID": auth.currentMembershipID ?? "",
      "currentLanguage": languageService.currentLanguage,
    };
    if(Platform.isAndroid){
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      data["manufacturer"] = deviceInfo.manufacturer;
      data["model"] = deviceInfo.model;
      data["androidVersion"] = deviceInfo.version.codename;
    }
    if(Platform.isIOS){
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      data["model"] = deviceInfo.model;
      data["iosVersion"] = deviceInfo.systemVersion;
    }
    return data;
  }
}
