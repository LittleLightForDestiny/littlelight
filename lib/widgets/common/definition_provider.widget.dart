//@dart=2.12
import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

typedef DefinitionWidgetBuilder<T> = Widget Function(T definition);

class DefinitionProviderWidget<T> extends StatefulWidget {
  final int hash;
  final DefinitionWidgetBuilder<T> widgetBuilder;
  final Widget? placeholder;
  DefinitionProviderWidget(this.hash, this.widgetBuilder,
      {this.placeholder, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DefinitionProviderWidgetState<T>();
  }
}

class DefinitionProviderWidgetState<T> extends State<DefinitionProviderWidget<T>> with ManifestConsumer{
  T? definition;
  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  void loadDefinition() async {
    definition = await manifest.getDefinition<T>(widget.hash);
    if(mounted == true){
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    final definition = this.definition;
    if(definition != null){
      return widget.widgetBuilder(definition);
    }
    final placeholder = widget.placeholder;
    if(placeholder != null){
      return placeholder;
    }
    return Container();
  }
}
