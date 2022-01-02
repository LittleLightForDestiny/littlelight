import 'package:flutter/material.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';

class VaultTabHeaderWidget extends TabHeaderWidget {
  VaultTabHeaderWidget() : super(null);

  @override
  VaultTabHeaderWidgetState createState() => new VaultTabHeaderWidgetState();
}

class VaultTabHeaderWidgetState extends TabHeaderWidgetState {
  @override
  void initState() {
    super.initState();
  }

  @override
  getDefinitions() {}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[emblemBackground(context), powerBar(context)],
        ),
        emblemIcon(context)
      ],
    );
  }

  Widget emblemIcon(BuildContext context) {
    double top = getTopPadding(context) + 10;
    return Positioned(
        left: 40,
        top: top,
        width: 56,
        height: 56,
        child: Image.asset("assets/imgs/vault-secondary-overlay.png",));
  }

  Widget emblemBackground(BuildContext context) {
    double height = getTopPadding(context) + kToolbarHeight;
    return Container(
        height: height,
        color: Theme.of(context).backgroundColor,
        child: Image.asset(
          "assets/imgs/vault-secondary-special.jpg",
          fit: BoxFit.cover,
          alignment: AlignmentDirectional.center,
        ));
  }

  Widget powerBar(BuildContext context) {
    return Container(height:2,color:Theme.of(context).colorScheme.secondary);
  }

  double getTopPadding(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }
}
