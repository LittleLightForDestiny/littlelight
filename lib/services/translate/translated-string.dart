import 'package:little_light/services/translate/app-translations.service.dart';

class TranslatedString{
  Map<String, String> languages = new Map();
  TranslatedString({
    String en,
    String fr,
    String es,
    String de,
    String it,
    String ja,
    String ptBR,
    String esMX,
    String ru,
    String pl,
    String ko,
    String zhCht
  }){
    languages['en'] = en;
    languages['fr'] = fr;
    languages['es'] = es;
    languages['de'] = de;
    languages['it'] = it;
    languages['ja'] = ja;
    languages['pt-br'] = ptBR;
    languages['es-mx'] = esMX;
    languages['ru'] = ru;
    languages['pl'] = pl;
    languages['ko'] = ko;
    languages['zh-cht'] = zhCht;
  }
  String get([String lang]){
    if(lang != null && languages.containsKey(lang)){
      return languages[lang];
    }
    if(languages[AppTranslations.currentLanguage] != null ){
      return languages[AppTranslations.currentLanguage];
    }
    return languages[AppTranslations.defaultLanguage];
  }
}