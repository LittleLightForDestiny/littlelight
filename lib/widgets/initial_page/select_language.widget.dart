import 'package:flutter/material.dart';
import 'package:little_light/services/translate/translate.service.dart';
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

  void getLanguage() async{
    selectedLanguage = await widget.translate.getLanguage();
    Locale locale = Localizations.localeOf(context, nullOk: true);
    if(selectedLanguage == null && locale != null){
      String localeName = "${locale.languageCode}-${locale.countryCode?.toLowerCase() ?? ''}";
      selectedLanguage = widget.availableLanguages.firstWhere((language)=>language==localeName, orElse: ()=>null);
    }
    if(selectedLanguage == null){
      selectedLanguage = widget.translate.fallbackLanguage;
    }
    widget.onChange(selectedLanguage);
    setState(() {});
  }

  void okClick() {
    widget.translate.currentLanguage = selectedLanguage;
    if (widget.onSelect != null) {
      widget.onSelect(selectedLanguage);
    }
  }

  List<Widget> getLanguageButtons(BuildContext context) {
    var query = MediaQuery.of(context);
    var factor = .25;
    if(query.size.shortestSide >= 600){
      factor = .1;
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
              color:selectedLanguage == language ? Theme.of(context).buttonColor : Colors.transparent,
              language: language));
    }).toList();
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(children: this.getLanguageButtons(context)),
      Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          widget.translate.languageNames[selectedLanguage] ?? selectedLanguage ?? "",
          textAlign: TextAlign.center,
        ),
      ),
      RaisedButton(
        onPressed: () {
          this.okClick();
        },
        child: TranslatedTextWidget("OK"),
      )
    ]);
  }
}
