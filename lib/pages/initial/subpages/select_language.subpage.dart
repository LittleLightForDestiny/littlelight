import 'dart:math';

import 'package:flutter/material.dart';
import 'package:little_light/core/providers/language/language.bloc.dart';
import 'package:little_light/pages/initial/notifiers/initial_page_state.notifier.dart';
import 'package:little_light/pages/initial/subpages/subpage_base.dart';
import 'package:little_light/pages/initial/widgets/language.button.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:provider/provider.dart';

class SelectLanguageSubPage extends StatefulWidget {
  SelectLanguageSubPage();

  @override
  SelectLanguageSubPageState createState() => SelectLanguageSubPageState();
}

class SelectLanguageSubPageState extends SubpageBaseState<SelectLanguageSubPage> {
  LanguageBloc get languageProvider => context.read<LanguageBloc>();
  String? _selectedLanguage;
  String get selectedLanguage =>
      _selectedLanguage ?? languageProvider.selectedLanguage ?? languageProvider.currentLanguage;
  set selectedLanguage(String value) => _selectedLanguage = value;

  void okClick() {
    languageProvider.selectedLanguage = selectedLanguage;
    Provider.of<InitialPageStateNotifier>(context, listen: false).languageSelected();
  }

  List<Widget> getLanguageButtons(BuildContext context) {
    final languages = languageProvider.languages;
    return languages.map<Widget>((language) {
      return LanguageButton(
          onPressed: () {
            this.setState(() {
              selectedLanguage = language.code;
            });
          },
          selected: language.code == selectedLanguage,
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
