import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

typedef String ExtractTextFromData(dynamic data);

class RefreshButtonWidget extends StatefulWidget {
  final NotificationService notifications = NotificationService();
  final ProfileService profile = ProfileService();
  RefreshButtonWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RefreshButtonWidgetState();
  }
}

class RefreshButtonWidgetState extends State<RefreshButtonWidget> with TickerProviderStateMixin {
  AnimationController rotationController;
  StreamSubscription<NotificationEvent> subscription;

  @override
  void initState() {
    rotationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    subscription = widget.notifications.listen((event) {
      handleNotification(event);
    });
    super.initState();
  }

  void dispose(){
    subscription.cancel();
    super.dispose();
  }

  void handleNotification(NotificationEvent event) async {
    switch (event.type) {

      case NotificationType.receivedUpdate:
      rotationController.stop();
      break;

      default:
        rotationController.repeat();
        break;
    }
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        buildRotatingIcon(),
        Positioned.fill(child:buildTapHandler()),
      ],
    );
  }

  Widget buildTapHandler(){
    return Material(
      color:Colors.transparent,
      child:InkWell(
        enableFeedback: !rotationController.isAnimating,
        onTap: (){ 
          if(!rotationController.isAnimating){
            widget.profile.fetchProfileData();
          }
        },
      )
    );
  }

  Widget buildRotatingIcon(){
    return RotationTransition(turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
    child: Icon(Icons.refresh, color:rotationController.isAnimating ? Colors.grey.shade500 : Colors.white),
    );
  }
}
