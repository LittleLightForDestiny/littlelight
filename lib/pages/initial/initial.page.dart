//@dart = 2.12

import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/subpages/authorization_request.subpage.dart';
import 'package:little_light/pages/initial/subpages/download_manifest_progress.subpage.dart';
import 'package:little_light/pages/initial/subpages/error.subpage.dart';
import 'package:little_light/pages/initial/subpages/select_language.subpage.dart';
import 'package:little_light/pages/initial/subpages/select_membership.subpage.dart';
import 'package:little_light/pages/initial/subpages/select_wishlists.subpage.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'notifiers/initial_page_state.notifier.dart';

class InitialPage extends StatefulWidget {
  InitialPage() : super();

  @override
  InitialPageState createState() => InitialPageState();
}

class InitialPageState extends State<InitialPage> with AuthConsumer, LanguageConsumer {
  @override
  Widget build(BuildContext context) => Scaffold(
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/imgs/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(child: buildContent(context))));

  Widget buildContent(BuildContext context) {
    final controller = Provider.of<InitialPageStateNotifier>(context);
    if (controller.error) {
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

  Widget buildLoadingAnim(BuildContext context) => Container(
      width: 96,
      child: Shimmer.fromColors(
        baseColor: Colors.blueGrey.shade300,
        highlightColor: Colors.white,
        child: Image.asset("assets/anim/loading.webp"),
      ));

  Widget languageSelectPage(BuildContext context) => SelectLanguageSubPage();

  Widget downloadManifestPage(BuildContext context) => DownloadManifestProgressSubPage();

  Widget authorizationRequestPage(BuildContext context) => AuthorizationRequestSubPage();

  Widget selectMembershipPage(BuildContext context) => SelectMembershipSubPage();
  
  Widget selectWishlistsPage(BuildContext context) => SelectWishlistsSubPage();

  Widget buildError(BuildContext context) => StartupErrorSubPage();
}
