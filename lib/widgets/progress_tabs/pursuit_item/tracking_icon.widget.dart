import 'package:flutter/material.dart';

class TrackingIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 20,
        height: 20,
        child: Stack(
            children: [buildBackground(context), buildAnimation(context)]));
  }

  buildBackground(BuildContext context) {
    return Image.asset("assets/imgs/ingame-quest-tracking-bg.png");
  }

  buildAnimation(BuildContext context) {
    return Image.asset("assets/imgs/ingame-quest-tracking-icon.png");
  }
}
