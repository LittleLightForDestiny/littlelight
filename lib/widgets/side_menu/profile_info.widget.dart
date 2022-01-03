//@dart=2.12

import 'package:bungie_api/destiny2.dart';
import 'package:bungie_api/groupsv2.dart';
import 'package:bungie_api/user.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/models/character_sort_parameter.dart';
import 'package:little_light/pages/initial/initial.page.dart';
import 'package:little_light/services/auth/auth.consumer.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/language/language.consumer.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/services/profile/profile.consumer.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/utils/shimmer_helper.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/manifest_text.widget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:timeago/timeago.dart' as timeago;

const Duration _kExpand = Duration(milliseconds: 200);

class ProfileInfoWidget extends StatefulWidget {

  final Widget? menuContent;
  ProfileInfoWidget({this.menuContent});

  @override
  createState() {
    return ProfileInfoState();
  }
}

class ProfileInfoState extends State<ProfileInfoWidget>
    with SingleTickerProviderStateMixin, AuthConsumer, LanguageConsumer, ProfileConsumer {
  UserMembershipData? account;
  GroupUserInfoCard? membership;

  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  AnimationController? _controller;
  Animation<double>? _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller?.drive(_easeInTween);
    _isExpanded = PageStorage.of(context)?.readState(context) ?? false;
    if (_isExpanded) _controller?.value = 1.0;

    if (auth.isLogged) {
      loadUser();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller?.forward();
      } else {
        _controller?.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {});
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget? child) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildProfileInfo(context),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor?.value ?? 0,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && (_controller?.isDismissed ?? false);
    if (_controller == null) return Container();
    return AnimatedBuilder(
      animation: _controller!.view,
      builder: _buildChildren,
      child: closed ? null : Container(color: Theme.of(context).backgroundColor, child: widget.menuContent),
    );
  }

  loadUser() async {
    UserMembershipData? membershipData = await auth.getMembershipData();
    GroupUserInfoCard? currentMembership = membershipData?.destinyMemberships?.firstWhereOrNull((m) => m.membershipId == auth.currentMembershipID);
    if (!mounted) return;
    setState(() {
      account = membershipData;
      membership = currentMembership;
    });
  }

  Widget buildProfileInfo(BuildContext context) {
    return Stack(children: [
      Column(
        children: <Widget>[
          Container(height: 150, child: background(context)),
          Container(height: kToolbarHeight, child: profileInfo(context)),
        ],
      ),
      Positioned(child: profilePicture(context), left: 8, bottom: 8, width: 72, height: 72)
    ]);
  }

  Widget get shimmer => ShimmerHelper.getDefaultShimmer(context);

  Widget background(context) {
    if (account == null) {
      return shimmer;
    }
    final profileThemeName = account?.bungieNetUser?.profileThemeName;
    if (profileThemeName == null) {
      return Container(
        color: Theme.of(context).backgroundColor,
      );
    }

    String? url = BungieApiService.url("/img/UserThemes/$profileThemeName/mobiletheme.jpg");
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: QueuedNetworkImage(
          imageUrl: url,
          placeholder: shimmer,
          fit: BoxFit.cover,
        )),
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.transparent, Colors.black54],
                  stops: [0, .2, .7, 1])),
        ),
        Positioned(bottom: 4, left: 88, child: buildActivityInfo(context))
      ],
    );
  }

  Widget buildActivityInfo(BuildContext context) {
    final lastCharacter = profile.getCharacters(CharacterSortParameter())?.first;
    if (lastCharacter == null) {
      return Container();
    }
    final lastPlayed = DateTime.tryParse(lastCharacter.dateLastPlayed ?? "");
    final currentSession = int.tryParse(lastCharacter.minutesPlayedThisSession ?? "");
    final time = lastPlayed != null
        ? timeago.format(lastPlayed, allowFromNow: true, locale: languageService.currentLanguage)
        : "";
    if (lastPlayed != null &&
        currentSession != null &&
        lastPlayed.add(Duration(minutes: currentSession + 10)).isBefore(DateTime.now().toUtc())) {
      return TranslatedTextWidget(
        "Last played {timeago}",
        replace: {'timeago': time.toLowerCase()},
        style: TextStyle(fontSize: 12, color: Colors.grey.shade100),
      );
    }
    final activities = profile.getCharacterActivities(lastCharacter.characterId);
    if (activities.currentActivityHash == 82913930) {
      return ManifestText<DestinyPlaceDefinition>(2961497387,
          textExtractor: (def) => "${def.displayProperties?.description}",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade100, fontWeight: FontWeight.bold));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ManifestText<DestinyActivityModeDefinition>(activities.currentActivityModeHash,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade100)),
      ManifestText<DestinyActivityDefinition>(activities.currentActivityHash,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade100, fontWeight: FontWeight.bold))
    ]);
  }

  Widget profilePicture(BuildContext context) {
    String? url = BungieApiService.url(account?.bungieNetUser?.profilePicturePath);

      return Container(
          decoration:
              BoxDecoration(
                color: LittleLightTheme.of(context).surfaceLayers.layer0,
                border: Border.all(width: 2, color: LittleLightTheme.of(context).surfaceLayers.layer3)),
          child: url == null ? shimmer : QueuedNetworkImage(
            imageUrl: url,
            placeholder: shimmer,
            fit: BoxFit.cover,
          ));
    
    
  }

  Widget profileInfo(context) {
    if (!auth.isLogged) {
      return Container(
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: MaterialButton(
              child: Container(
                alignment: Alignment.centerLeft,
                child: TranslatedTextWidget("Tap to Login", textAlign: TextAlign.left),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InitialPage(),
                    ));
              },
            )),
            IconButton(
              enableFeedback: false,
              icon: Transform.rotate(angle: -(_heightFactor?.value ?? 0) * 1.5, child: Icon(Icons.settings)),
              onPressed: _handleTap,
            )
          ],
        ),
      );
    }
    bool isCrossSaveAccount = membership?.membershipId == account?.primaryMembershipId;
    PlatformData? platform = isCrossSaveAccount ? PlatformData.crossPlayData : membership?.membershipType?.data;
    return Container(
        color: platform?.color,
        padding: EdgeInsets.only(left: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(platform?.icon)),
            Expanded(child: Text(membership?.displayName ?? "")),
            IconButton(
              enableFeedback: false,
              icon: Transform.rotate(angle: -(_heightFactor?.value ?? 0) * 1.5, child: Icon(Icons.settings)),
              onPressed: _handleTap,
            )
          ],
        ));
  }
}
