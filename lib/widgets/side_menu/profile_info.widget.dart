import 'package:bungie_api/models/destiny_activity_definition.dart';
import 'package:bungie_api/models/destiny_activity_mode_definition.dart';
import 'package:bungie_api/models/destiny_place_definition.dart';
import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:little_light/screens/initial.screen.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/services/user_settings/character_sort_parameter.dart';
import 'package:little_light/widgets/common/manifest_text.widget.dart';
import 'package:little_light/widgets/common/queued_network_image.widget.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

const Duration _kExpand = Duration(milliseconds: 200);

class ProfileInfoWidget extends StatefulWidget {
  final AuthService auth = AuthService();
  final ProfileService profile = ProfileService();
  final List<Widget> menuItems;
  ProfileInfoWidget({this.menuItems});

  @override
  createState() {
    return ProfileInfoState();
  }
}

class ProfileInfoState extends State<ProfileInfoWidget>
    with SingleTickerProviderStateMixin {
  GeneralUser bungieNetUser;
  GroupUserInfoCard selectedMembership;

  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);

  AnimationController _controller;
  Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _isExpanded = PageStorage.of(context)?.readState(context) ?? false;
    if (_isExpanded) _controller.value = 1.0;

    if (widget.auth.isLogged) {
      loadUser();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {});
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Container(
      color: Colors.grey.shade900,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildProfileInfo(context),
          ClipRect(
            child: Align(
              heightFactor: _heightFactor.value,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool closed = !_isExpanded && _controller.isDismissed;
    return AnimatedBuilder(
      animation: _controller.view,
      builder: _buildChildren,
      child: closed ? null : Column(children: widget.menuItems),
    );
  }

  loadUser() async {
    UserMembershipData membershipData = await widget.auth.getMembershipData();
    GroupUserInfoCard currentMembership = await widget.auth.getMembership();
    if(!mounted) return;
    setState(() {
      bungieNetUser = membershipData?.bungieNetUser;
      selectedMembership = currentMembership;
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
      Positioned(
          child: profilePicture(context),
          left: 8,
          bottom: 8,
          width: 72,
          height: 72)
    ]);
  }

  Widget background(context) {
    if (!widget.auth.isLogged) {
      return Container(
          alignment: Alignment.center,
          child: TranslatedTextWidget("Not logged in"));
    }
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .1),
        highlightColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .3),
        child: Container(color: Colors.white));
    if (bungieNetUser?.profileThemeName != null) {
      String url = BungieApiService.url(
          "/img/UserThemes/${bungieNetUser.profileThemeName}/mobiletheme.jpg");
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
                    colors: [
                  Colors.black26,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black54
                ],
                    stops: [
                  0,
                  .2,
                  .7,
                  1
                ])),
          ),
          Positioned(bottom: 4, left: 88, child: buildActivityInfo(context))
        ],
      );
    }
    return shimmer;
  }

  Widget buildActivityInfo(BuildContext context) {
    var lastCharacter =
        widget.profile.getCharacters(CharacterSortParameter()).first;
    var lastPlayed = DateTime.parse(lastCharacter.dateLastPlayed);
    var currentSession = lastCharacter.minutesPlayedThisSession;
    var time = timeago.format(lastPlayed, allowFromNow: true, locale: StorageService.getLanguage());
    if (lastPlayed
        .add(Duration(minutes: int.parse(currentSession) + 10))
        .isBefore(DateTime.now().toUtc())) {
      return TranslatedTextWidget(
        "Last played {timeago}",
        replace: {'timeago': time.toLowerCase()},
        style: TextStyle(fontSize: 12, color: Colors.grey.shade100),
      );
    }
    var activities =
        widget.profile.getCharacterActivities(lastCharacter.characterId);
    if(activities.currentActivityHash ==  82913930){
      return ManifestText<DestinyPlaceDefinition>(2961497387,
        textExtractor: (def)=>def.displayProperties.description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade100, fontWeight: FontWeight.bold));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ManifestText<DestinyActivityModeDefinition>(
          activities.currentActivityModeHash,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade100)),
      ManifestText<DestinyActivityDefinition>(activities.currentActivityHash,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade100, fontWeight: FontWeight.bold))
    ]);
  }

  Widget profilePicture(context) {
    if (!widget.auth.isLogged) {
      return Container();
    }
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Colors.grey.shade500,
        highlightColor: Colors.grey.shade400,
        child: Container(color: Colors.white));
    if (bungieNetUser != null && bungieNetUser.profileThemeName != null) {
      String url = BungieApiService.url(bungieNetUser.profilePicturePath);
      return QueuedNetworkImage(
        imageUrl: url,
        placeholder: shimmer,
        fit: BoxFit.cover,
      );
    }
    return shimmer;
  }

  Widget profileInfo(context) {
    if (!widget.auth.isLogged) {
      return Container(
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: FlatButton(
              child: Container(
                alignment: Alignment.centerLeft,
                child: TranslatedTextWidget("Tap to Login",
                    textAlign: TextAlign.left),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InitialScreen(),
                    ));
              },
            )),
            IconButton(
              icon: Transform.rotate(
                  angle: -_heightFactor.value * 1.5,
                  child: Icon(Icons.settings)),
              onPressed: _handleTap,
            )
          ],
        ),
      );
    }
    PlatformData platform =
        PlatformData.getPlatform(selectedMembership?.membershipType);
    return Container(
        color: platform.color,
        padding: EdgeInsets.only(left: 80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(platform.iconData)),
            Expanded(child: Text(selectedMembership?.displayName ?? "")),
            IconButton(
              icon: Transform.rotate(
                  angle: -_heightFactor.value * 1.5,
                  child: Icon(Icons.settings)),
              onPressed: _handleTap,
            )
          ],
        ));
  }
}
