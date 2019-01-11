import 'package:bungie_api/models/user_membership_data.dart';
import 'package:flutter/material.dart';
import 'package:little_light/widgets/initial_page/plaftorm.button.dart';

typedef void PlatformSelectCallback(int membershipType);

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
                  widget.onSelect(membership.membershipType);
                },
              )));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [Wrap(children: this.getButtons())]);
  }
}
