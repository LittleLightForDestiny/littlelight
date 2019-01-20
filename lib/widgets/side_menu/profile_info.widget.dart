import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:shimmer/shimmer.dart';

const Duration _kExpand = Duration(milliseconds: 200);

class ProfileInfoWidget extends StatefulWidget {
  final AuthService auth = new AuthService();
  final List<Widget> children;
  ProfileInfoWidget({this.children});

  @override
  createState() {
    return ProfileInfoState();
  }
}

class ProfileInfoState extends State<ProfileInfoWidget> with SingleTickerProviderStateMixin {
  GeneralUser bungieNetUser;
  UserInfoCard selectedMembership;
  
  static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

  AnimationController _controller;
  Animation<double> _heightFactor;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kExpand, vsync: this);
    _heightFactor = _controller.drive(_easeInTween);
    _isExpanded = PageStorage.of(context)?.readState(context) ?? false;
    if (_isExpanded)
      _controller.value = 1.0;

    loadUser();
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
          if (!mounted)
            return;
          setState(() {
          });
        });
      }
      PageStorage.of(context)?.writeState(context, _isExpanded);
    });
  }

  Widget _buildChildren(BuildContext context, Widget child) {
    return Container(
      color:Colors.grey.shade900,
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
      child: closed ? null : Column(children: widget.children),
    );
  }

  loadUser() async {
    SavedMembership membership = await widget.auth.getMembership();
    setState(() {
      bungieNetUser = membership.bungieNetUser;
      selectedMembership = membership.selectedMembership;
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
      Positioned(child: profilePicture(context),
          left:8,
          bottom: 8,
          width:72,
          height:72
          )
    ]);
  }

  Widget background(context) {
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .1),
        highlightColor: Color.lerp(Theme.of(context).backgroundColor,
            Theme.of(context).primaryColor, .3),
        child: Container(color: Colors.white));
    if (bungieNetUser != null && bungieNetUser.profileThemeName != null) {
      String url =
          "${BungieApiService.baseUrl}/img/UserThemes/${bungieNetUser.profileThemeName}/mobiletheme.jpg";
      return CachedNetworkImage(
        imageUrl: url,
        placeholder: shimmer,
        fit: BoxFit.cover,
      );
    }
    return shimmer;
  }

  Widget profilePicture(context){
    Shimmer shimmer = Shimmer.fromColors(
        baseColor: Colors.grey.shade500,
        highlightColor: Colors.grey.shade400,
        child: Container(color: Colors.white));
    if (bungieNetUser != null && bungieNetUser.profileThemeName != null) {
      String url =
          "${BungieApiService.baseUrl}/${bungieNetUser.profilePicturePath}";
      return CachedNetworkImage(
        imageUrl: url,
        placeholder: shimmer,
        fit: BoxFit.cover,
      );
    }
    return shimmer;
  }

  Widget profileInfo(context) {
    PlatformData platform = PlatformData.getPlatform(selectedMembership?.membershipType ?? 0);
    return Container(
        color: platform.color,
        padding: EdgeInsets.only(left:80),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 8),
              child:Icon(platform.iconData)
              ),
            Expanded(child:Text(selectedMembership?.displayName ?? "")),
            IconButton(icon: Icon(Icons.settings),
            onPressed: _handleTap,)
          ],
        ));
  }
}
