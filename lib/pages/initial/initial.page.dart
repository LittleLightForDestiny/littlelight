//@dart = 2.12

import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/subpages/authorization_request.subpage.dart';
import 'package:little_light/pages/initial/subpages/download_manifest_progress.subpage.dart';
import 'package:little_light/pages/initial/subpages/error.subpage.dart';
import 'package:little_light/pages/initial/subpages/select_language.subpage.dart';
import 'package:little_light/pages/initial/subpages/select_membership.subpage.dart';
import 'package:little_light/pages/initial/subpages/select_wishlists.subpage.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:provider/provider.dart';

import 'notifiers/initial_page_state.notifier.dart';

class InitialPage extends StatefulWidget {
  const InitialPage() : super();

  @override
  InitialPageState createState() => InitialPageState();
}

class InitialPageState extends State<InitialPage> with AuthConsumer {
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/imgs/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(child: buildContent(context))));

  Widget buildContent(BuildContext context) {
    final controller = Provider.of<InitialPageStateNotifier>(context);
    if (controller.error != null) {
      return buildError(context);
    }
    if (controller.loading) {
      return buildLoadingAnim(context);
    }
    switch (controller.phase) {
      case InitialPagePhase.Loading:
      case InitialPagePhase.EnsureCache:
        return buildLoadingAnim(context);
      case InitialPagePhase.LanguageSelect:
        return languageSelectPage(context);
      case InitialPagePhase.ManifestDownload:
        return downloadManifestPage(context);
      case InitialPagePhase.AuthorizationRequest:
        return authorizationRequestPage(context);
      case InitialPagePhase.MembershipSelect:
        return selectMembershipPage(context);
      case InitialPagePhase.WishlistsSelect:
        return selectWishlistsPage(context);
    }
  }

  Widget buildLoadingAnim(BuildContext context) => LoadingAnimWidget();

  Widget languageSelectPage(BuildContext context) =>
      const SelectLanguageSubPage();

  Widget downloadManifestPage(BuildContext context) =>
      const DownloadManifestProgressSubPage();

  Widget authorizationRequestPage(BuildContext context) =>
      const AuthorizationRequestSubPage();

  Widget selectMembershipPage(BuildContext context) =>
      const SelectMembershipSubPage();

  Widget selectWishlistsPage(BuildContext context) =>
      const SelectWishlistsSubPage();

  Widget buildError(BuildContext context) => const StartupErrorSubPage();
}
