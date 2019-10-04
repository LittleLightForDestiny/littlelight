import 'package:bungie_api/models/group_user_info_card.dart';
import 'package:flutter/material.dart';
import 'package:little_light/utils/platform_data.dart';

class PlatformButton extends RaisedButton {
  final GroupUserInfoCard platform;
  PlatformButton(this.platform, {@required Function onPressed})
      : super(onPressed: onPressed);

  @override
  Widget get child {
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
  @override
    Color get color{
      PlatformData data = PlatformData.getPlatform(platform.membershipType);
      return data.color;
    }
}
