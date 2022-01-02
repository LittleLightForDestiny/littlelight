import 'package:flutter/material.dart';
import 'package:little_light/exceptions/exception_handler.dart';
import 'package:little_light/widgets/common/loading_anim.widget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

class FloatingContentState<T extends StatefulWidget> extends State<T>
    with TickerProviderStateMixin {
  bool loading = true;
  String language;
  Widget previousContent;
  String previousTitle;
  Widget currentContent;
  String currentTitle;
  AnimationController controller;
  CurvedAnimation animation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

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
    ExceptionHandler.context = context;
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

  Widget loaderAnim(BuildContext context) => LoadingAnimWidget();

  Widget getContentContainer() {
    return AnimatedContentBox(
      currentContent,
      previousContent,
      currentTitle,
      previousTitle,
      this,
      animation: animation,
      language: language,
    );
  }

  changeContent(Widget content, String title) {
    if (!mounted) return;
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

  changeTitleLanguage(String language) {
    setState(() {
      this.language = language;
    });
  }
}

class AnimatedContentBox extends AnimatedWidget {
  final String currentTitle;
  final String language;
  final Widget currentContent;
  final String previousTitle;
  final Widget previousContent;
  final TickerProvider ticker;
  AnimatedContentBox(this.currentContent, this.previousContent,
      this.currentTitle, this.previousTitle, this.ticker,
      {Key key, Animation<double> animation, this.language})
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
                color: Theme.of(context).colorScheme.primaryVariant,
                child: Padding(
                    child: TranslatedTextWidget(currentTitle,
                        key: Key("$currentTitle $language"),
                        language: language,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.all(16)),
              ),
              Padding(
                child: currentContent,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              ),
              DecoratedBox(
                  child: Padding(padding: EdgeInsets.all(4)),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryVariant))
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
                        language: language,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
                    language: language,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
