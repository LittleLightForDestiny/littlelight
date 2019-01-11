import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:shimmer/shimmer.dart';

class FloatingContentState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  bool loading = true;
  Widget previousContent;
  String previousTitle;
  Widget currentContent;
  String currentTitle;
  AnimationController controller;
  CurvedAnimation animation;

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    super.initState();

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (currentContent == null) {
          setState(() {
            this.loading = true;
          });
        }
      }
    });
  }

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
              child: this.loading ? loaderAnim(context) : getContentContainer(),
            )));
  }

  Widget loaderAnim(BuildContext context) {
    return Container(
        width: 96,
        child:
            Shimmer.fromColors(
              baseColor: Colors.blueGrey.shade300, 
              highlightColor: Colors.white,
              child: Image.asset("assets/anim/loading.webp"),));
  }

  Widget getContentContainer() {
    return new AnimatedContentBox(
      currentContent,
      previousContent,
      currentTitle,
      previousTitle,
      this,
      animation: animation,
    );
  }

  changeContent(Widget content, String title) {
    setState(() {
      loading = content == null;
      previousContent = currentContent;
      previousTitle = currentTitle;
      currentContent = content;
      currentTitle = title;
    });
    controller.reset();
    controller.forward();
  }

  changeTitle(String title) {
    setState(() {
      this.currentTitle = title;
    });
  }
}

class AnimatedContentBox extends AnimatedWidget {
  final String currentTitle;
  final Widget currentContent;
  final String previousTitle;
  final Widget previousContent;
  final TickerProvider ticker;
  AnimatedContentBox(this.currentContent, this.previousContent,
      this.currentTitle, this.previousTitle, this.ticker,
      {Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    if (previousContent == null && currentContent == null) {
      return Container();
    }
    if (previousContent == null) {
      return buildEnteringAnim(context);
    }

    if (currentContent == null) {
      return buildExitingAnim(context);
    }

    return buildIntermediateAnim(context);
  }

  Widget buildEnteringAnim(BuildContext context) {
    return new Card(
        margin: EdgeInsets.all(0),
        color: Theme.of(context).backgroundColor,
        shape: Border.all(width: 0),
        child: SizeTransition(
          sizeFactor: listenable,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                    child: TranslatedTextWidget(currentTitle,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.all(16)),
              ),
              Padding(
                child: currentContent,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              ),
              DecoratedBox(
                  child: Padding(padding: EdgeInsets.all(4)),
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor))
            ],
          ),
        ));
  }

  Widget buildExitingAnim(BuildContext context) {
    Tween<double> sizeFactor = Tween<double>(begin: 1, end: 0);
    return new Card(
        margin: EdgeInsets.all(0),
        color: Theme.of(context).backgroundColor,
        shape: Border.all(width: 0),
        child: SizeTransition(
          sizeFactor: sizeFactor.animate(listenable),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                child: Padding(
                    child: TranslatedTextWidget(previousTitle,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.all(16)),
              ),
              Padding(
                child: previousContent,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              ),
              DecoratedBox(
                  child: Padding(padding: EdgeInsets.all(4)),
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor))
            ],
          ),
        ));
  }

  Widget buildIntermediateAnim(BuildContext context) {
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
                child: TranslatedTextWidget(currentTitle,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                padding: EdgeInsets.all(16)),
          ),
          Padding(
            child: AnimatedSwitcher(
                duration: Duration(milliseconds: 500), child: currentContent),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          ),
          DecoratedBox(
              child: Padding(padding: EdgeInsets.all(4)),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor))
        ],
      ),
    );
  }
}

class TranslatedTextWidtet {
}
