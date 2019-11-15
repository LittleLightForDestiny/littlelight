import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/initial_page/plaftorm.button.dart';

typedef void PlatformSelectCallback(String membershipType);

class SelectPlatformWidget extends StatefulWidget {
  final String title = "Select Platform";
  final UserMembershipData membershipData;
  final PlatformSelectCallback onSelect;

  SelectPlatformWidget({this.membershipData, this.onSelect});

  @override
  SelectPlatformWidgetState createState() => new SelectPlatformWidgetState();
}

class SelectPlatformWidgetState extends State<SelectPlatformWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getButtons() {
    return widget.membershipData.destinyMemberships.map((membership) {
      return FractionallySizedBox(
          widthFactor: 1 / widget.membershipData.destinyMemberships.length,
          child: Padding(
              padding: EdgeInsets.all(4),
              child: PlatformButton(
                membership,
                onPressed: () {
                  widget.onSelect(membership.membershipId);
                },
              )));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.membershipData.destinyMemberships.length == 0) {
      return Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(8),
              child: TranslatedTextWidget(
                  "Looks like you dont play destiny on this Bungie.net account. Try logging into a different account.")),
          Container(
              padding: EdgeInsets.all(8),
              constraints: BoxConstraints(minWidth: double.infinity),
              child: RaisedButton(
                child: TranslatedTextWidget("Login"),
                onPressed: () {
                  widget.onSelect(null);
                },
              ))
        ],
      );
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Wrap(children: this.getButtons())]);
  }
}
