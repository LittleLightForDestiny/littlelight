import 'package:timeago/timeago.dart';

class RuMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => 'через';
  @override
  String suffixAgo() => 'назад';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'минуту';
  @override
  String aboutAMinute(int minutes) => 'минуту';
  @override
  String minutes(int minutes) => '$minutes минут';
  @override
  String aboutAnHour(int minutes) => 'час';
  @override
  String hours(int hours) => '$hours часов';
  @override
  String aDay(int hours) => 'день';
  @override
  String days(int days) => '$days дней';
  @override
  String aboutAMonth(int days) => 'месяц';
  @override
  String months(int months) => '$months месяцев';
  @override
  String aboutAYear(int year) => 'год';
  @override
  String years(int years) => '$years лет';
  @override
  String wordSeparator() => ' ';
}
