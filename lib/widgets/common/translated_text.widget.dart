import 'package:flutter/material.dart';
import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:provider/provider.dart';

typedef ExtractTextFromData = String Function(dynamic data);

class TranslatedTextWidget extends StatelessWidget {
  final String text;
  final String? language;
  final Map<String, String> replace;
  final bool uppercase;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  final bool? softWrap;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final double? textScaleFactor;

  TranslatedTextWidget(this.text,
      {Key? key,
      this.replace = const {},
      this.language,
      this.maxLines,
      this.overflow,
      this.semanticsLabel,
      this.softWrap,
      this.style,
      this.textAlign,
      this.textDirection,
      this.textScaleFactor,
      this.uppercase = false})
      : super(key: key ?? Key(text));

  @override
  Widget build(BuildContext context) {
    String text = context.watch<LanguageBloc>().translate(
          this.text,
          languageCode: this.language,
          replace: this.replace,
        );
    if (uppercase) {
      text = text.toUpperCase();
    }
    return Text(text,
        maxLines: maxLines,
        overflow: overflow,
        semanticsLabel: semanticsLabel,
        softWrap: softWrap,
        style: style ?? DefaultTextStyle.of(context).style,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        key: Key(text));
  }
}
