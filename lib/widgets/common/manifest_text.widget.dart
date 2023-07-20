import 'package:flutter/material.dart';
import 'package:little_light/core/utils/logger/logger.wrapper.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/string/replace_string_variables.dart';

typedef ExtractTextFromData<T> = String? Function(T definition);

class ManifestText<T> extends StatelessWidget with ManifestConsumer {
  final int? definitionHash;
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

  ManifestText(this.definitionHash,
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
    final text = desiredText(context);
    return Text(
      text,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
    );
  }

  String desiredText(BuildContext context) {
    String? resultText;
    final def = context.definition<T>(definitionHash);
    try {
      if (def == null) return "";
      final extractor = textExtractor;
      if (extractor != null) {
        resultText = extractor(def);
      } else {
        resultText = (def as dynamic).displayProperties.name;
      }
      resultText = resultText?.replaceBungieVariables(context);
    } catch (e) {
      logger.error(e);
      return "";
    }
    if (resultText == null) return "";
    if (uppercase) {
      return resultText.toUpperCase();
    }
    return resultText;
  }
}
