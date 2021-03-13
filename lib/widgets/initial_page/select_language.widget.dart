import 'package:flutter/material.dart';
import 'package:little_light/services/storage/storage.service.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/utils/media_query_helper.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';

import 'package:little_light/widgets/initial_page/language.button.dart';

typedef void LanguageSelectCallback(String languageCode);

class SelectLanguageWidget extends StatefulWidget {
  final String title = "Select Language";
  final List<String> availableLanguages;
  final LanguageSelectCallback onChange;
  final LanguageSelectCallback onSelect;
  final TranslateService translate = new TranslateService();

  SelectLanguageWidget({this.availableLanguages, this.onChange, this.onSelect});

  @override
  SelectLanguageWidgetState createState() => new SelectLanguageWidgetState();
}

class SelectLanguageWidgetState extends State<SelectLanguageWidget> {
  String selectedLanguage;

  @override
  void initState() {
    super.initState();
    getLanguage();
  }

  void getLanguage() async {
    await Future.delayed(Duration(milliseconds: 1));
    selectedLanguage = StorageService.getLanguage();
    Locale locale = Localizations.localeOf(context);
    if (selectedLanguage == null && locale != null) {
      String localeName =
          "${locale.languageCode}-${locale.countryCode?.toLowerCase() ?? ''}";
      selectedLanguage = widget.availableLanguages
          .firstWhere((language) => language == localeName, orElse: () => null);
    }
    if (selectedLanguage == null) {
      selectedLanguage = widget.translate.fallbackLanguage;
    }
    widget.onChange(selectedLanguage);
    setState(() {});
  }

  void okClick() {
    StorageService.setLanguage(selectedLanguage);
    if (widget.onSelect != null) {
      widget.onSelect(selectedLanguage);
    }
  }

  List<Widget> getLanguageButtons(BuildContext context) {
    var query = MediaQueryHelper(context);
    var factor = 1.0;
    if (query.tabletOrBigger || query.isLandscape) {
      factor = .25;
    }
    List<String> languages = widget.availableLanguages;
    List<Widget> buttons = languages.map<Widget>((language) {
      return FractionallySizedBox(
          widthFactor: factor,
          child: LanguageButton(
              onPressed: () {
                this.setState(() {
                  selectedLanguage = language;
                  widget.onChange(selectedLanguage);
                });
              },
              selected: language == selectedLanguage,
              language: language));
    }).toList();
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Container(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height - 210),
          child: SingleChildScrollView(
              child: Wrap(children: this.getLanguageButtons(context)))),
      ElevatedButton(
        onPressed: () {
          this.okClick();
        },
        child: TranslatedTextWidget("OK"),
      )
    ]);
  }
}
