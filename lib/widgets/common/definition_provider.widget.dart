import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

typedef DefinitionWidgetBuilder<T> = Widget Function(T? definition);

class DefinitionProviderWidget<T> extends StatelessWidget with ManifestConsumer {
  final int hash;
  final DefinitionWidgetBuilder<T> widgetBuilder;
  final Widget? placeholder;
  DefinitionProviderWidget(this.hash, this.widgetBuilder, {this.placeholder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T?>(
      key: Key("definition_provider_widget_${T.toString()}_$hash"),
      future: manifest.getDefinition<T>(hash),
      builder: ((context, snapshot) {
        final data = snapshot.data;
        if (snapshot.hasData && data != null) return widgetBuilder(data);
        return placeholder ?? Container();
      }),
    );
  }
}
