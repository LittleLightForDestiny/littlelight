import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/platform_data.dart';

class PlatformButton extends StatelessWidget {
  final GroupUserInfoCard platform;
  final Function onPressed;

  PlatformButton(this.platform, {@required this.onPressed}) : super();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(primary: color),
        onPressed: onPressed,
        child: _child);
  }

  Widget get _child {
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

  Color get color {
    PlatformData data = PlatformData.getPlatform(platform.membershipType);
    return data.color;
  }
}
