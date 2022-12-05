import 'dart:async';

import 'package:flutter/material.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';

typedef ExtractTextFromData<T> = FutureOr<String>? Function(T definition);

class ManifestText<T> extends StatelessWidget with ManifestConsumer {
  final int? hash;
  final bool uppercase;
  final ExtractTextFromData<T>? textExtractor;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  final bool? softWrap;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final double? textScaleFactor;

  ManifestText(this.hash,
      {Key? key,
      this.uppercase = false,
      this.textExtractor,
      this.maxLines,
      this.overflow,
      this.semanticsLabel,
      this.softWrap,
      this.style,
      this.textAlign,
      this.textDirection,
      this.textScaleFactor});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: desiredText(context),
        builder: (context, text) => Text(
              text.data ?? "",
              maxLines: maxLines,
              overflow: overflow,
              semanticsLabel: semanticsLabel,
              softWrap: softWrap,
              style: style,
              textAlign: textAlign,
              textDirection: textDirection,
              textScaleFactor: textScaleFactor,
            ));
  }

  Future<String> desiredText(BuildContext context) async {
    String? resultText;
    try {
      final def = await manifest.getDefinition<T>(hash);
      if (def == null) return "";
      final extractor = textExtractor;
      if (extractor != null) {
        resultText = await extractor(def);
      } else {
        resultText = (def as dynamic).displayProperties.name;
      }
    } catch (e) {
      print(e);
      return "";
    }
    if (resultText == null) return "";
    if (uppercase) {
      return resultText.toUpperCase();
    }
    return resultText;
  }
}
