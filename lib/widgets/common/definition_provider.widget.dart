import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

typedef DefinitionWidgetBuilder<T> = Widget Function(T definition);

class DefinitionProviderWidget<T> extends FutureBuilder<T> {
  final ManifestService manifest = new ManifestService();
  final int hash;
  DefinitionProviderWidget(this.hash, DefinitionWidgetBuilder<T> widgetBuilder, {Widget placeholder})
      : super(builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return widgetBuilder(snapshot.data);
          }
          if(placeholder != null){
            return placeholder;
          }
          return Container();
        });

  @override
  Future<T> get future => manifest.getDefinition<T>(hash);
}
