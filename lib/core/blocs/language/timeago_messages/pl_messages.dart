import 'package:timeago/timeago.dart';

class PlMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => 'temu';
  @override
  String suffixFromNow() => 'od tego momentu';
  @override
  String lessThanOneMinute(int seconds) => 'chwilę';
  @override
  String aboutAMinute(int minutes) => 'około minutę';
  @override
  String minutes(int minutes) =>
      _is234(minutes) ? '$minutes minuty' : '$minutes minut';
  @override
  String aboutAnHour(int minutes) => 'około godzinę';
  @override
  String hours(int hours) => _is234(hours) ? '$hours godziny' : '$hours godzin';
  @override
  String aDay(int hours) => 'dzień';
  @override
  String days(int days) => '$days dni';
  @override
  String aboutAMonth(int days) => 'około miesiąc';
  @override
  String months(int months) =>
      _is234(months) ? '$months miesiące' : '$months miesięcy';
  @override
  String aboutAYear(int year) => 'około rok';
  @override
  String years(int years) => _is234(years) ? '$years lata' : '$years lat';
  @override
  String wordSeparator() => ' ';

  bool _is234(int v) {
    var mod = v % 10;
    return (mod == 2 || mod == 3 || mod == 4) && (v / 10) != 1;
  }
}
