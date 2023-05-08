import 'dart:async';

import 'package:flutter/material.dart';

class TimedUpdater extends StatefulWidget {
  final Duration every;
  final Widget child;

  const TimedUpdater({Key? key, required this.every, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimedUpdaterState();
}

class _TimedUpdaterState extends State<TimedUpdater> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(widget.every, (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
