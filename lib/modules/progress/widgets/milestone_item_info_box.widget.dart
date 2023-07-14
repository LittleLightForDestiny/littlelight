import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';

class MilestoneItemInfoBoxWidget extends StatelessWidget {
  final Widget? title;
  final VoidCallback? onTap;
  final Widget content;

  const MilestoneItemInfoBoxWidget({Key? key, this.title, required this.content, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.theme.surfaceLayers.layer0.withOpacity(.8),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.all(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: context.theme.surfaceLayers.layer2,
                    ),
                    child: title,
                  ),
                content,
              ],
            ),
          ),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: onTap,
            ),
          )),
        ],
      ),
    );
  }
}
