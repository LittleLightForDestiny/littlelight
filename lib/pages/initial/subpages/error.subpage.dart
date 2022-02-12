//@dart=2.12

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/pages/initial/errors/authorization_failed.error.dart';
import 'package:little_light/pages/initial/errors/manifest_download.error.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StartupErrorSubPage extends StatefulWidget {
  StartupErrorSubPage();

  @override
  StartupErrorSubPageState createState() => new StartupErrorSubPageState();
}

class StartupErrorSubPageState extends SubpageBaseState<StartupErrorSubPage> with AuthConsumer {
  InitialPageStateNotifier get controller => context.read<InitialPageStateNotifier>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildTitle(BuildContext context) {
    if (controller.error is ManifestDownloadError) {
      return manifestDownloadErrorTitle;
    }
    if (controller.error is AuthorizationFailedError) {
      return authorizationErrorTitle;
    }
    return genericErrorTitle;
  }

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(children: [buildDescription(context), buildOptions(context)]));

  Widget buildDescription(BuildContext context) {
    if(controller.error is ManifestDownloadError){
      return buildMultilineDescription([manifestDownloadErrorMessage, manifestDownloadErrorInstruction]);
    }
    if (controller.error is AuthorizationFailedError) {
      return buildMultilineDescription([authorizationErrorMessage, authorizationErrorInstructions]);
    }
    return buildMultilineDescription([unexpectedErrorMessage, clearAndRestartInstructions]);
  }

  Widget buildOptions(BuildContext context) {
    if (controller.error is ManifestDownloadError) {
      return buildMultiButtonOptions([retryManifestDownloadOption, checkBungieNetTwitterOption, clearDataAndRestartOption]);
    }
    if (controller.error is AuthorizationFailedError) {
      return buildMultiButtonOptions([openBungieLoginOption, checkBungieNetTwitterOption, checkLittleLightD2TwitterOption]);
    }
    return buildMultiButtonOptions([restartOption, clearDataAndRestartOption]);
  }

  Widget buildMultilineDescription(List<Widget> lines) => Container(
        constraints: BoxConstraints(maxWidth: 400),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: lines),
        padding: EdgeInsets.all(8),
      );

  Widget buildMultiButtonOptions(List<Widget> buttons) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: buttons));



  /// Title options
  Widget get genericErrorTitle => TranslatedTextWidget("Unexpected error");
  Widget get authorizationErrorTitle => TranslatedTextWidget("Authorization error");
  Widget get manifestDownloadErrorTitle => TranslatedTextWidget("Error downloading Database");

  /// Description parts
  Widget get unexpectedErrorMessage => TranslatedTextWidget(
        "There was an unexpected error starting Little Light.",
        textAlign: TextAlign.center,
      );
  Widget get clearAndRestartInstructions => TranslatedTextWidget(
        "Please try to restart the app, and if that doesn't solve the issue, clear data and restart.",
        textAlign: TextAlign.center,
      );

  Widget get authorizationErrorMessage => TranslatedTextWidget(
        "There was an error while authorizing your account with Bungie's servers.",
        textAlign: TextAlign.center,
      );

  Widget get authorizationErrorInstructions => TranslatedTextWidget(
        "Please try to login again. If this keeps happening, check if there's any ongoing maintenance on Bungie's server through @BungieHelp or @LittleLightD2 twitter.",
        textAlign: TextAlign.center,
      );

  Widget get manifestDownloadErrorMessage => TranslatedTextWidget(
        "There was an error while downloading Destiny 2 database from Bungie's servers.",
        textAlign: TextAlign.center,
      );

  Widget get manifestDownloadErrorInstruction => TranslatedTextWidget(
        "Please check your internet connection and try again. If this keeps happening, check if Bungie's servers aren't on maintenance via @BungieHelp.",
        textAlign: TextAlign.center,
      );

  
  /// Button options

  Widget get restartOption => ElevatedButton(
        onPressed: controller.restartApp,
        child: TranslatedTextWidget("Restart Little Light"),
      );

  Widget get clearDataAndRestartOption => ElevatedButton(
        onPressed: controller.clearDataAndRestart,
        child: TranslatedTextWidget("Clear data and restart"),
        style: ElevatedButton.styleFrom(primary: Theme.of(context).errorColor),
      );

  Widget get openBungieLoginOption => ElevatedButton(
        onPressed: () => auth.openBungieLogin(false),
        child: TranslatedTextWidget("Authorize with Bungie.net"),
      );

  Widget get checkBungieNetTwitterOption => ElevatedButton(
      onPressed: () => launch("https://twitter.com/BungieHelp"),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(FontAwesomeIcons.twitter), Container(width: 8), TranslatedTextWidget("Check @BungieHelp")],
      ));

  Widget get checkLittleLightD2TwitterOption => ElevatedButton(
      onPressed: () => launch("https://twitter.com/LittleLightD2"),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(FontAwesomeIcons.twitter), Container(width: 8), TranslatedTextWidget("Check @LittleLightD2")],
      ));

  Widget get retryManifestDownloadOption => ElevatedButton(
      onPressed: controller.retryManifestDownload,
      child: TranslatedTextWidget("Retry download"),
      );
}
