import 'package:timeago/timeago.dart';

class EnMessages implements LookupMessages {
  String prefixAgo() => '';
  String prefixFromNow() => 'in';
  String suffixAgo() => 'ago';
  String suffixFromNow() => '';
  String lessThanOneMinute(int seconds) => 'less than a minute';
  String aboutAMinute(int minutes) => 'a minute';
  String minutes(int minutes) => '$minutes minutes';
  String aboutAnHour(int minutes) => 'about an hour';
  String hours(int hours) => '$hours hours';
  String aDay(int hours) => '$hours hours';
  String days(int days) => '$days days';
  String aboutAMonth(int days) => '$days days';
  String months(int months) => '$months months';
  String aboutAYear(int year) => 'about a year';
  String years(int years) => '$years years';
  String wordSeparator() => ' ';
}