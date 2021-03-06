import 'package:bungie_api/enums/bungie_membership_type.dart';
import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/platform_data.dart';

class PlatformButton extends StatelessWidget {
  final GroupUserInfoCard platform;
  final Function onPressed;

  PlatformButton(this.platform, {@required this.onPressed}) : super();

  @override
  Widget build(BuildContext context) {
    return Material(
        color: color,
        child: InkWell(
          child: Stack(children: [
            Center(child: _mainPlatform),
            Positioned(right: 8, bottom: 8, child: _subPlatformsWidget)
          ]),
          onTap: onPressed,
        ));
  }

  Widget get _mainPlatform {
    PlatformData data = PlatformData.getPlatform(platform.membershipType);
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Icon(data.iconData, size: 30)),
            Text(platform.displayName)
          ],
        ));
  }

  List<BungieMembershipType> get _subPlatforms =>
      platform.applicableMembershipTypes
          ?.where((m) => m != platform.membershipType)
          ?.toList() ??
      [];

  Widget get _subPlatformsWidget {
    if (_subPlatforms?.length == 0) return Container();
    return Container(
        child: Row(
            children: _subPlatforms.map((m) => _subPlatformBadge(m)).toList()));
  }

  Widget _subPlatformBadge(BungieMembershipType membershipType) {
    var data = PlatformData.getPlatform(membershipType);
    return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
            color: data.color, borderRadius: BorderRadius.circular(4)),
        margin: EdgeInsets.only(left: 4),
        child: Icon(
          data.iconData,
          size: 24,
        ));
  }

  Color get color {
    PlatformData data = PlatformData.getPlatform(platform.membershipType);
    return data.color;
  }
}
