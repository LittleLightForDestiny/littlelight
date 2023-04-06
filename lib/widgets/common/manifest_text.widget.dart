import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/profile/profile.bloc.dart';
import 'package:little_light/services/manifest/manifest.consumer.dart';
import 'package:little_light/shared/utils/extensions/number/to_decimal.dart';
import 'package:provider/provider.dart';

typedef ExtractTextFromData<T> = String? Function(T definition);

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
    final def = context.definition<T>(hash);
    final profile = context.watch<ProfileBloc>();
    try {
      if (def == null) return "";
      final extractor = textExtractor;
      if (extractor != null) {
        resultText = extractor(def);
      } else {
        resultText = (def as dynamic).displayProperties.name;
      }
      final varFinder = RegExp(r"\{var:(\d*)\}");
      final hasVars = varFinder.hasMatch(resultText ?? "");
      if (hasVars) {
        resultText = resultText?.replaceAllMapped(varFinder, (match) {
          final hash = match.group(1);
          final replacement = profile.stringVariable(hash);
          final replacementStr = replacement?.toDecimal(context);
          return replacementStr ?? match.group(0) ?? "";
        });
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
