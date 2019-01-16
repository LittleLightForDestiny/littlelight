import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

typedef Widget CreateWidget<T>(T definitionType);

class DefinitionProviderWidget<T> extends StatefulWidget {
  final ManifestService manifest = new ManifestService();
  final int hash;
  final CreateWidget<T> createWidget;
  final Widget placeholder;
  DefinitionProviderWidget(this.hash, this.createWidget, {this.placeholder});

  @override
  DefinitionProviderWidgetState<T> createState() {
    return DefinitionProviderWidgetState<T>();
  }
}

class DefinitionProviderWidgetState<T> extends State<DefinitionProviderWidget>{
  T definition;
  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  loadDefinition() async{
    definition = await widget.manifest.getDefinition<T>(widget.hash);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    if(definition != null){
      return widget.createWidget(definition);
    }
    if(widget.placeholder != null){
      return widget.placeholder;
    }
    return Container();
  }
}
