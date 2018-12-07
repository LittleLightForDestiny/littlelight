import 'package:flutter/material.dart';
import 'package:little_light/services/translate/app-translations.service.dart';
import 'package:little_light/services/translate/pages/select-language-translation.dart';
import 'package:little_light/widgets/initial-page/language.button.dart';
typedef void LanguageSelectCallback(String languageCode);
class SelectLanguageWidget extends StatefulWidget {
  final SelectLanguageTranslation translation = new SelectLanguageTranslation();
  final List<String> availableLanguages;
  final LanguageSelectCallback onChange;
  final LanguageSelectCallback onSelect;

  SelectLanguageWidget({this.availableLanguages, this.onChange, this.onSelect});

  @override
  SelectLanguageWidgetState createState() => new SelectLanguageWidgetState();
}

class SelectLanguageWidgetState
  extends State<SelectLanguageWidget> {
    String selectedLanguage;
  

  @override
  void initState() {
    selectedLanguage = AppTranslations.currentLanguage;
    super.initState();
  }

  void okClick(){
    AppTranslations.currentLanguage = selectedLanguage;
    if(widget.onSelect != null){
      widget.onSelect(selectedLanguage);
    }
  }

  List<Widget> getLanguageButtons() {
    List<Widget> buttons = widget.availableLanguages.map<Widget>((language) {
      return new LanguageButton(
          onPressed: () {
            this.setState(() {
              selectedLanguage = language;
              widget.onChange(selectedLanguage);
            });
          },
          selected: selectedLanguage == language,
          language: language);
    }).toList();
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      Wrap(children: this.getLanguageButtons()),
      Padding(
        padding: EdgeInsets.all(8),
        child:
            Text(this.widget.translation.languageNames.get(selectedLanguage),
            textAlign: TextAlign.center,),
      ),
      RaisedButton(
        onPressed: () {
          this.okClick();
        },
        child: Text(AppTranslations.common.ok.get(selectedLanguage)),
      )
    ]);
  }
}
