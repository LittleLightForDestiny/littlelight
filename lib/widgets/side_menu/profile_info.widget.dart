import 'package:bungie_api/models/general_user.dart';
import 'package:bungie_api/models/user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:little_light/services/auth/auth.service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/utils/platform_data.dart';
import 'package:shimmer/shimmer.dart';

class ProfileInfoWidget extends StatefulWidget {
  final AuthService auth = new AuthService();
  final BungieApiService api = new BungieApiService();
  @override
  State<StatefulWidget> createState() {
    return new ProfileInfoState();
  }
}

class ProfileInfoState extends State<ProfileInfoWidget> {
  GeneralUser bungieNetUser;
  UserInfoCard selectedMembership;
  @override
  initState() {
    super.initState();
    loadUser();
  }

  loadUser() async {
    SavedMembership membership = await widget.auth.getMembership();
    setState(() {
      bungieNetUser = membership.bungieNetUser;
      selectedMembership = membership.selectedMembership;
    });
  }

  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: <Widget>[
          Container(height: 120, child: background(context)),
          Container(height: 40, child: profileInfo(context)),
        ],
      ),
      Positioned(child: profilePicture(context),
          left:20,
          bottom: 20,
          width:80,
          height:80
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text(selectedMembership?.displayName ?? ""),
            Padding(
              padding:EdgeInsets.symmetric(horizontal: 8),
              child:Icon(platform.iconData)
              )
          ],
        ));
  }
}
