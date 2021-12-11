import 'package:flutter/material.dart';
import 'package:little_light/services/storage/export.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:timeago/timeago.dart' as timeago;

typedef String ExtractTextFromData(dynamic data);

class ExpiryDateWidget extends StatefulWidget {
  final String date;
  final double fontSize;
  ExpiryDateWidget(this.date, {Key key, this.fontSize = 12}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExpiryDateWidgetState();
  }
}

class ExpiryDateWidgetState extends State<ExpiryDateWidget> {
  bool expired = false;
  String expiresIn = "";

  @override
  void initState() {
    super.initState();
    updateDuration();
  }

  updateDuration() async {
    var expiry = DateTime.parse(widget.date);
    expired = DateTime.now().toUtc().isAfter(expiry);
    if (expired) {
      setState(() {});
      return;
    }
    var locale = StorageService.getLanguage();
    expiresIn = timeago.format(expiry, allowFromNow: true, locale: locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var style = TextStyle(
        color: Colors.red.shade300,
        fontSize: widget.fontSize,
        fontStyle: FontStyle.italic);
    if (expired) {
      return TranslatedTextWidget(
        "Expired",
        style: style,
      );
    }
    return TranslatedTextWidget(
      "Expires {timeFromNow}",
      replace: {'timeFromNow': expiresIn},
      key: Key(expiresIn),
      style: style,
    );
  }
}
