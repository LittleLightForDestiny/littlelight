//@dart=2.12
import 'package:flutter/material.dart';

abstract class SubpageBaseState<T extends StatefulWidget> extends State<T> {
  bool open = false;

  TextStyle get titleStyle => Theme.of(context).textTheme.headline1 ?? TextStyle();
  @override
  void initState() {
    super.initState();
    delayedOpen();
  }

  delayedOpen() async {
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      open = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.only(top:mq.viewPadding.top, bottom:mq.viewPadding.bottom,),
      child:AnimatedContainer(
        decoration: BoxDecoration(
            color: open ? Theme.of(context).backgroundColor : Theme.of(context).colorScheme.onSurface,
            border: Border(
                bottom: BorderSide(
              color: open ? Theme.of(context).appBarTheme.backgroundColor! : Theme.of(context).colorScheme.onSurface,
              width: open ? 4 : 0,
            ))),
        duration: Duration(milliseconds: 300),
        constraints: BoxConstraints(maxHeight: open ? mq.size.height : 1),
        child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Container(
                color: Theme.of(context).appBarTheme.backgroundColor!,
                padding: EdgeInsets.all(8).add(EdgeInsets.only(
                  left: mq.viewPadding.left,
                  right: mq.viewPadding.right,
                )),
                child: DefaultTextStyle(style: titleStyle, child: buildTitle(context)),
              ),
              Container(
                padding: EdgeInsets.all(8).add(EdgeInsets.only(left:mq.viewPadding.left, right:mq.viewPadding.right,)),
                child: buildContent(context),
              ),
            ]))));
  }

  Widget buildTitle(BuildContext context);
  Widget buildContent(BuildContext context);
}
