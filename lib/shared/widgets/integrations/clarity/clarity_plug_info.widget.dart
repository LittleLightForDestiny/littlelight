import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/clarity/clarity_data.bloc.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_class_names.dart';
import 'package:little_light/core/blocs/clarity/models/d2_clarity_description.dart';
import 'package:little_light/core/blocs/language/language.consumer.dart';
import 'package:little_light/core/theme/littlelight.theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ClarityPlugInfoWidget extends StatelessWidget {
  final int plugHash;

  ClarityPlugInfoWidget(int this.plugHash);

  @override
  Widget build(BuildContext context) {
    final descriptionWidget = buildDescriptions(context);
    if (descriptionWidget == null && 1 == 1) return Container();
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer1,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          if (descriptionWidget != null) descriptionWidget,
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.surfaceLayers.layer0,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.all(2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => launchUrlString("https://www.d2clarity.com/"),
              child: Container(
                width: 20,
                height: 20,
                child: Image.asset('assets/imgs/clarity_logo.png'),
                padding: EdgeInsets.only(right: 4),
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => launchUrlString("https://www.d2clarity.com/"),
                child: Text(
                  "Clarity – Destiny 2 Research insights".translate(context),
                  style: context.textTheme.highlight.copyWith(height: 1.2, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => launchUrlString("https://ko-fi.com/d2clarity"),
              child: Container(
                width: 20,
                height: 20,
                child: Image.asset('assets/imgs/ko-fi-icon.png'),
                padding: EdgeInsets.only(right: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? buildDescriptions(BuildContext context) {
    final clarityState = context.watch<ClarityDataBloc>();
    final descriptions = clarityState.getPerkDescriptions(plugHash);
    if (descriptions == null) return null;
    final descriptionWidgets = descriptions.map((d) => buildDescription(context, d)).whereType<Widget>();
    if (descriptionWidgets.isEmpty) return null;
    return Container(
      padding: EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: descriptionWidgets.toList(),
      ),
    );
  }

  Widget? buildDescription(BuildContext context, ClarityDescription description) {
    final lines = description.linesContent;
    if (lines == null) return null;
    return Wrap(
        children: lines.map((e) {
      final bold = e.classNames?.contains(ClarityClassNames.Bold) ?? false;
      return Text(
        e.text ?? "",
        style: bold ? context.textTheme.highlight : context.textTheme.body,
      );
    }).toList());
  }
}
