//@dart=2.12

import 'package:flutter/material.dart';
import 'package:little_light/services/language/language.consumer.dart';

typedef String ExtractTextFromData(dynamic data);

class TranslatedTextWidget extends StatefulWidget with LanguageConsumer{
  final String text;
  final String? language;
  final Map<String,String> replace;
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
  State<StatefulWidget> createState() {
    return TranslatedTextWidgetState();
  }
}

class TranslatedTextWidgetState extends State<TranslatedTextWidget> with LanguageConsumer{
  String? translatedText;
  @override
  void initState() {
    super.initState();
    loadTranslation();
  }

  Future<void> loadTranslation() async {
    if(widget.language != null){
      translatedText = await languageService.getTranslation(widget.text, replace:widget.replace, languageCode: widget.language);  
    }else{
      translatedText = await languageService.getTranslation(widget.text, replace:widget.replace);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String text = translatedText ?? widget.text;
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
      key:Key(text)
    );
  }
}
