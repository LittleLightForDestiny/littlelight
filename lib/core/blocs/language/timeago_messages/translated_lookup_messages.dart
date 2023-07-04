import 'package:little_light/core/blocs/language/language.bloc.dart';
import 'package:timeago/timeago.dart';

extension on String {
  String translate(
    LanguageBloc bloc, {
    Map<String, String> replace = const {},
    String? overrideDefaultText,
  }) =>
      bloc.translate(this, replace: replace, overrideDefaultText: overrideDefaultText);
}

class TranslatedLookupMessages implements LookupMessages {
  final LanguageBloc bloc;

  TranslatedLookupMessages(this.bloc);

  @override
  String prefixAgo() => "time_ago_prefix(default:empty)".translate(bloc, overrideDefaultText: '');
  @override
  String prefixFromNow() => "time_from_now_prefix(default:in)".translate(bloc, overrideDefaultText: 'in');
  @override
  String suffixAgo() => "time_ago_suffix(default:ago)".translate(bloc, overrideDefaultText: 'ago');
  @override
  String suffixFromNow() => "time_from_now_suffix(defualt:empty)".translate(bloc, overrideDefaultText: '');
  @override
  String lessThanOneMinute(int seconds) => "less than a minute".translate(bloc);
  @override
  String aboutAMinute(int minutes) => "a minute".translate(bloc);
  @override
  String minutes(int minutes) => "{minutes} minutes".translate(bloc, replace: {"minutes": "$minutes"});
  @override
  String aboutAnHour(int minutes) => "about an hour".translate(bloc);
  @override
  String hours(int hours) => "{hours} hours".translate(bloc, replace: {"hours": "$hours"});
  @override
  String aDay(int hours) => "{hours} hours".translate(bloc, replace: {"hours": "$hours"});
  @override
  String days(int days) => "{days} days".translate(bloc, replace: {"days": "$days"});
  @override
  String aboutAMonth(int days) => "{days} days".translate(bloc, replace: {"days": "$days"});
  @override
  String months(int months) => "{months} months".translate(bloc, replace: {"months": "$months"});
  @override
  String aboutAYear(int year) => "{months} months".translate(bloc, replace: {"months": "$months"});
  @override
  String years(int years) => "{years} years".translate(bloc, replace: {"years": "$years"});
  @override
  String wordSeparator() => ' ';
}
