import 'package:flutter/material.dart';
import 'package:little_light/widgets/common/definition_provider.widget.dart';

typedef ExtractTextFromData<T> = String Function(T definition);

class ManifestText<T> extends DefinitionProviderWidget<T> {
  ManifestText(hash,
      {Key key,
      bool uppercase = false,
      ExtractTextFromData<T> textExtractor,
      int maxLines,
      TextOverflow overflow,
      String semanticsLabel,
      bool softWrap,
      TextStyle style,
      TextAlign textAlign,
      TextDirection textDirection,
      double textScaleFactor})
      : super(hash, (definition) {
          String text;
          if (textExtractor != null) {
            text = textExtractor(definition);
          } else {
            text = (definition as dynamic).displayProperties.name;
          }
          if (uppercase) {
            text = text.toUpperCase();
          }
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
        },
            placeholder: Text(
              " ",
              maxLines: maxLines,
              overflow: overflow,
              semanticsLabel: semanticsLabel,
              softWrap: softWrap,
              style: style,
              textAlign: textAlign,
              textDirection: textDirection,
              textScaleFactor: textScaleFactor,
            ),
            key: key);
}
