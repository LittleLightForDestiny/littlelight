import 'package:flutter/material.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:little_light/shared/utils/helpers/media_query_helper.dart';
import 'package:little_light/shared/widgets/headers/header.wiget.dart';

typedef BuildCallback = Widget Function(BuildContext context);

abstract class BaseBottomSheet<ReturnType> extends StatelessWidget {
  const BaseBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildContainer(context, (context) {
      final header = this.buildHeader(context);
      return Container(
        constraints: BoxConstraints(maxHeight: context.mediaQuery.size.height * .8),
        color: context.theme.surfaceLayers.layer1,
        padding: EdgeInsets.only(
          left: context.mediaQuery.padding.left,
          right: context.mediaQuery.padding.right,
          bottom: context.mediaQuery.viewInsets.bottom,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          if (header != null)
            Container(
              padding: EdgeInsets.all(8),
              child: HeaderWidget(child: header),
            ),
          Flexible(child: buildContent(context)),
        ]),
      );
    });
  }

  Widget buildContainer(BuildContext context, BuildCallback builder) {
    return Builder(
      builder: builder,
    );
  }

  Widget? buildHeader(BuildContext context);

  Widget buildContent(BuildContext context);

  Future<ReturnType?> show(BuildContext context) async {
    final result = await showModalBottomSheet(context: context, builder: (context) => this, isScrollControlled: true);
    if (result is ReturnType) return result;
    return null;
  }
}
