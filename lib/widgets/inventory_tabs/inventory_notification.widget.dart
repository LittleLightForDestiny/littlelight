import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:shimmer/shimmer.dart';

class InventoryNotificationWidget extends StatefulWidget {
  final profile = ProfileService();
  final double barHeight;

  InventoryNotificationWidget(
      {Key key, this.barHeight = kBottomNavigationBarHeight})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InventoryNotificationWidgetState();
  }
}

class InventoryNotificationWidgetState
    extends State<InventoryNotificationWidget> {
  bool busy = false;
  StreamSubscription<ProfileEvent> subscription;
  String message = "";
  @override
  void initState() {
    super.initState();
    subscription = widget.profile.broadcaster.listen((event) {
      bool busy;
      String message = "";
      if (event == ProfileEvent.REQUESTED_UPDATE) {
        busy = true;
        message = "Updating";
      }
      if (event == ProfileEvent.RECEIVED_UPDATE) {
        busy = false;
      }

      setState(() {
        this.message = message;
        this.busy = busy;
      });
    });
  }

  @override
  void deactivate() {
    subscription.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom:0, 
      left:0,
      right: 0,
      height:bottomPadding + widget.barHeight * 2,
      child:IgnorePointer(
        child: AnimatedCrossFade(
      duration: Duration(milliseconds: 300),
      firstChild: Container(
        alignment: Alignment.bottomCenter,
          child: idleWidget(context),
          height: bottomPadding + widget.barHeight * 2),
      secondChild: Container(
          child: busyWidget(context),
          height: bottomPadding + widget.barHeight * 2),
      crossFadeState:
          busy ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    )));
  }

  Widget idleWidget(context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Stack(fit: StackFit.expand, children: [
      Positioned(
          left: 0,
          right: 0,
          height: 2,
          bottom: bottomPadding + widget.barHeight,
          child: Container(
            color: Colors.blueGrey.shade700,
          ))
    ]);
  }

  Widget busyWidget(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    List<Widget> stackChildren = [
      Positioned(
          left: 0,
          right: 0,
          bottom: bottomPadding + widget.barHeight,
          child: shimmerBar(context)),
      Positioned(
          left: 0,
          right: 0,
          bottom: bottomPadding + widget.barHeight + 2,
          child: busyText(context)),
    ];
    if (bottomPadding > 1) {
      stackChildren.add(Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: bottomPadding,
        child: bottomPaddingShimmer(context),
      ));
    }
    return Stack(fit: StackFit.expand, children: stackChildren);
  }

  Widget busyText(BuildContext context) {
    return Container(
        alignment: Alignment.bottomRight,
        padding: EdgeInsets.all(8),
        child: Shimmer.fromColors(
            baseColor: Colors.blueGrey.shade400,
            highlightColor: Colors.grey.shade100,
            child: (TranslatedTextWidget(message,uppercase: true,
                style: TextStyle(fontWeight: FontWeight.w700)))));
  }

  Widget shimmerBar(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.blueGrey.shade700,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 2, color: Colors.white));
  }

  Widget bottomPaddingShimmer(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.transparent,
        highlightColor: Colors.grey.shade300,
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
        ));
  }
}
