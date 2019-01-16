import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
typedef t<T> = Widget Function<T>(T item);
class DefinitionProviderWidget<T> extends FutureBuilder<T> {
  final ManifestService manifest = new ManifestService();
  final int hash;
  final Widget placeholder;
  DefinitionProviderWidget(this.hash,
      {final AsyncWidgetBuilder<T> builder, this.placeholder})
      : super(builder: builder);

  @override
  Future<T> get future => manifest.getDefinition<T>(hash);
}