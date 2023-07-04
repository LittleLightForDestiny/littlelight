import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

abstract class BaseBottomSheet<ReturnType> extends StatelessWidget {
  const BaseBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final header = this.buildHeader(context);
    return Container(
      color: context.theme.surfaceLayers.layer1,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        if (header != null)
          Container(
            padding: EdgeInsets.all(8),
            child: HeaderWidget(child: header),
          ),
        Flexible(child: buildContent(context)),
      ]),
    );
  }

  Widget? buildHeader(BuildContext context);

  Widget buildContent(BuildContext context);

  Future<ReturnType?> show(BuildContext context) async {
    final result = await showModalBottomSheet(context: context, builder: (context) => this);
    if (result is ReturnType) return result;
    return null;
  }
}
