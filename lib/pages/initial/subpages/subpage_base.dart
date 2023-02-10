import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

abstract class SubpageBaseState<T extends StatefulWidget> extends State<T> {
  bool open = false;

  TextStyle get titleStyle => LittleLightTheme.of(context).textTheme.title;
  @override
  void initState() {
    super.initState();
    delayedOpen();
  }

  delayedOpen() async {
    await Future.delayed(const Duration(milliseconds: 1));
    setState(() {
      open = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    double maxWidth = 500;
    final showHorizontalBorders = mq.size.width > maxWidth;
    final borderSide = BorderSide(
      color: open ? LittleLightTheme.of(context).surfaceLayers.layer3 : LittleLightTheme.of(context).onSurfaceLayers,
      width: open ? 4 : 0,
    );
    return Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.only(
          top: mq.viewPadding.top,
          bottom: mq.viewPadding.bottom,
        ),
        child: AnimatedContainer(
            decoration: BoxDecoration(
                color: open ? LittleLightTheme.of(context).surfaceLayers : LittleLightTheme.of(context).onSurfaceLayers,
                border: Border(
                    left: showHorizontalBorders ? borderSide : BorderSide.none,
                    right: showHorizontalBorders ? borderSide : BorderSide.none,
                    bottom: borderSide)),
            duration: const Duration(milliseconds: 300),
            constraints: BoxConstraints(maxHeight: open ? mq.size.height : 1),
            child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    color: LittleLightTheme.of(context).surfaceLayers.layer3,
                    padding: const EdgeInsets.all(8).add(EdgeInsets.only(
                      left: mq.viewPadding.left,
                      right: mq.viewPadding.right,
                    )),
                    child: DefaultTextStyle(style: titleStyle, child: buildTitle(context)),
                  ),
                  Container(
                    padding: EdgeInsets.all(showHorizontalBorders ? 16 : 8) +
                        EdgeInsets.only(
                          left: mq.viewPadding.left,
                          right: mq.viewPadding.right,
                        ),
                    child: buildContent(context),
                  ),
                ]))));
  }

  Widget buildTitle(BuildContext context);
  Widget buildContent(BuildContext context);
}
