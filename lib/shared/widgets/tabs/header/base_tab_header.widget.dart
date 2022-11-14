import 'package:flutter/material.dart';

abstract class BaseTabHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).viewPadding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildBackgroundContainer(context),
        Positioned(
          left: kToolbarHeight,
          top: paddingTop + kToolbarHeight * .3,
          width: 64,
          height: 64,
          child: buildIcon(context),
        ),
      ],
    );
  }

  Widget _buildBackgroundContainer(BuildContext context) {
    final paddingTop = MediaQuery.of(context).viewPadding.top;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
        height: paddingTop + kToolbarHeight,
        child: buildBackground(context),
      ),
      Container(
        height: 2,
        child: buildProgressBar(context),
      )
    ]);
  }

  Widget buildBackground(BuildContext context);

  Widget buildProgressBar(BuildContext context);

  Widget buildIcon(BuildContext context);
}
