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

class ShortTranslatedLookupMessages implements LookupMessages {
  final LanguageBloc bloc;

  ShortTranslatedLookupMessages(this.bloc);

  @override
  String prefixAgo() => "short_time_ago_prefix".translate(bloc, overrideDefaultText: '');
  @override
  String prefixFromNow() => "short_time_from_now_prefix(default:empty)".translate(bloc, overrideDefaultText: '');
  @override
  String suffixAgo() => "short_time_ago_suffix(default:empty)".translate(bloc, overrideDefaultText: '');
  @override
  String suffixFromNow() => "short_time_from_now_suffix(default:empty)".translate(bloc, overrideDefaultText: '');
  @override
  String lessThanOneMinute(int seconds) => "<1m".translate(bloc);
  @override
  String aboutAMinute(int minutes) => "1m".translate(bloc);
  @override
  String minutes(int minutes) => "{minutes}m".translate(bloc, replace: {"minutes": "$minutes"});
  @override
  String aboutAnHour(int minutes) => "<1h".translate(bloc);
  @override
  String hours(int hours) => "{hours}h".translate(bloc, replace: {"hours": "$hours"});
  @override
  String aDay(int hours) => "{hours}h".translate(bloc, replace: {"hours": "$hours"});
  @override
  String days(int days) => "{days}d".translate(bloc, replace: {"days": "$days"});
  @override
  String aboutAMonth(int days) => "{days}d".translate(bloc, replace: {"days": "$days"});
  @override
  String months(int months) => "{months}m".translate(bloc, replace: {"months": "$months"});
  @override
  String aboutAYear(int year) => "{months}m".translate(bloc, replace: {"months": "$months"});
  @override
  String years(int years) => "{years}y".translate(bloc, replace: {"years": "$years"});
  @override
  String wordSeparator() => ' ';
}
