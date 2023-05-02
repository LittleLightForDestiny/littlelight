import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

typedef DefinitionWidgetBuilder<T> = Widget Function(T? definition);

class DefinitionProviderWidget<T> extends StatelessWidget with ManifestConsumer {
  final int definitionHash;
  final DefinitionWidgetBuilder<T> widgetBuilder;
  final Widget? placeholder;
  DefinitionProviderWidget(this.definitionHash, this.widgetBuilder, {this.placeholder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final def = context.definition<T>(definitionHash);
    if (def != null) return widgetBuilder(def);
    return placeholder ?? Container();
  }
}
