//@dart=2.12
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/pages/initial/widgets/language.button.dart';
import 'package:little_light/services/language/language.consumer.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

class SelectLanguageSubPage extends StatefulWidget {
  SelectLanguageSubPage();

  @override
  SelectLanguageSubPageState createState() => new SelectLanguageSubPageState();
}

class SelectLanguageSubPageState extends SubpageBaseState<SelectLanguageSubPage> with LanguageConsumer {
  String? _selectedLanguage;
  String get selectedLanguage =>
      _selectedLanguage ?? languageService.selectedLanguage ?? languageService.currentLanguage;
  set selectedLanguage(String value) => _selectedLanguage = value;

  @override
  void initState() {
    super.initState();
  }

  void okClick() {
    languageService.selectedLanguage = _selectedLanguage;
    Provider.of<InitialPageStateNotifier>(context, listen: false).languageSelected();
  }

  List<Widget> getLanguageButtons(BuildContext context) {
    List<String> languages = languageService.languageNames.keys.toList();
    return languages.map<Widget>((language) {
      return LanguageButton(
          onPressed: () {
            this.setState(() {
              selectedLanguage = language;
            });
          },
          selected: language == selectedLanguage,
          language: language);
    }).toList();
  }

  @override
  Widget buildTitle(BuildContext context) => TranslatedTextWidget(
        "Select Language",
        key: Key("title$selectedLanguage"),
        language: selectedLanguage,
      );

  @override
  Widget buildContent(BuildContext context) => Container(
      constraints: BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
              constraints: BoxConstraints(maxHeight: max(240, MediaQuery.of(context).size.height - 300)),
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: this.getLanguageButtons(context),
              ))),
          ElevatedButton(
            onPressed: () {
              this.okClick();
            },
            child: TranslatedTextWidget(
              "OK",
              key: Key("okButton$selectedLanguage"),
            ),
          )
        ],
      ));
}
