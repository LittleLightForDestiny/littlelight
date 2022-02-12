// @dart=2.9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_light/services/notification/notification.package.dart';
import 'package:little_light/services/profile/profile.consumer.dart';


typedef String ExtractTextFromData(dynamic data);

class RefreshButtonWidget extends StatefulWidget {

  final EdgeInsets padding;
  RefreshButtonWidget({Key key, this.padding}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RefreshButtonWidgetState();
  }
}

class RefreshButtonWidgetState extends State<RefreshButtonWidget> with TickerProviderStateMixin, ProfileConsumer, NotificationConsumer {
  AnimationController rotationController;
  StreamSubscription<NotificationEvent> subscription;

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    subscription = notifications.listen((event) {
      handleNotification(event);
    });
  }

  void dispose(){
    subscription.cancel();
    rotationController.dispose();
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
        Container(
          padding: widget.padding,
          child:buildRotatingIcon()),
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
            profile.fetchProfileData();
          }
        },
      )
    );
  }

  Widget buildRotatingIcon(){
    return RotationTransition(turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
    child: Icon(Icons.refresh, color:rotationController.isAnimating ? Colors.grey.shade500 : Theme.of(context).colorScheme.onSurface),
    );
  }
}
