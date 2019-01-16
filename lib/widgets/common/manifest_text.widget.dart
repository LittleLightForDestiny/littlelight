import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.service.dart';

typedef String ExtractTextFromData<T>(T data);

class ManifestText<T> extends StatefulWidget {
  final bool uppercase;
  final int hash;
  final ExtractTextFromData<T> textExtractor;
  final int maxLines;
  final TextOverflow overflow;
  final String semanticsLabel;
  final bool softWrap;
  final TextStyle style;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final double textScaleFactor;

  final ManifestService _manifest = new ManifestService();

  ManifestText(this.hash,
      {Key key,
      this.maxLines,
      this.overflow,
      this.semanticsLabel,
      this.softWrap,
      this.style,
      this.textAlign,
      this.textDirection,
      this.textScaleFactor,
      this.uppercase = false,
      this.textExtractor})
      : super(key: key);

  @override
  State<ManifestText> createState() {
    return new ManifestTextState<T>();
  }
}

class ManifestTextState<T> extends State<ManifestText> {
  dynamic definition;

  @override
  void initState() {
    super.initState();
    loadDefinition();
  }

  Future<void> loadDefinition() async {
    definition = await widget._manifest.getDefinition<T>(widget.hash);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = " ";
    try {
      if (widget.textExtractor == null) {
        text = (definition as dynamic).displayProperties.name;
      } else {
        text = widget.textExtractor(definition);
      }
    } catch (e) {}
    if (widget.uppercase) {
      text = text.toUpperCase();
    }
    return Text(
      text,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      semanticsLabel: widget.semanticsLabel,
      softWrap: widget.softWrap,
      style: widget.style,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      textScaleFactor: widget.textScaleFactor,
    );
  }
}
