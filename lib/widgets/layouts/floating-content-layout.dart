import 'package:flutter/material.dart';

class FloatingContentState<T extends StatefulWidget> extends State<T> with TickerProviderStateMixin{
  bool loading = true;
  Widget currentContent;
  String currentTitle;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/imgs/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: new Center(
              child: this.loading
                  ? new Image.asset("assets/anim/loading-light.webp")
                  : AnimatedSize( 
                      curve: Curves.easeOut,
                      vsync: this,
                      duration:Duration(milliseconds: 500),
                      child: getContentContainer(currentContent, currentTitle),
                    )
            )));
  }

  Widget getContentContainer(Widget content, String title) {
    if(content == null){
      return new Card();
    }
    return new Card(
      margin: EdgeInsets.all(0),
      color: Theme.of(context).backgroundColor,
      shape: Border.all(width: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                  child: 
                  Text(title,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  padding: EdgeInsets.all(16))),
          Padding(
            child: content,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          ),
          DecoratedBox(
              child: Padding(padding: EdgeInsets.all(4)),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor))
        ],
      ),
    );
  }

  changeContent(Widget content, String title) {
    setState(() {
      loading = false;
      currentContent = content;
      currentTitle = title;
    });
  }

  changeTitle(String title){
    setState(() {
      this.currentTitle = title;
    });
  }
}
