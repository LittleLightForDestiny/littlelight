import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

typedef DefinitionWidgetBuilder<T> = Widget Function(T? definition);

class DefinitionProviderWidget<T> extends StatelessWidget with ManifestConsumer {
  final int presentationNodeHash;
  final DefinitionWidgetBuilder<T> widgetBuilder;
  final Widget? placeholder;
  DefinitionProviderWidget(this.presentationNodeHash, this.widgetBuilder, {this.placeholder, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T?>(
      key: Key("definition_provider_widget_${T.toString()}_$presentationNodeHash"),
      future: manifest.getDefinition<T>(presentationNodeHash),
      builder: ((context, snapshot) {
        final data = snapshot.data;
        if (snapshot.hasData && data != null) return widgetBuilder(data);
        return placeholder ?? Container();
      }),
    );
  }
}
