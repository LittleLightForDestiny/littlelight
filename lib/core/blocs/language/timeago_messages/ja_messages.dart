import 'package:timeago/timeago.dart';

class JaMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '今から';
  @override
  String suffixAgo() => '前';
  @override
  String suffixFromNow() => '後';
  @override
  String lessThanOneMinute(int seconds) => '1 分未満e';
  @override
  String aboutAMinute(int minutes) => '約 1 分';
  @override
  String minutes(int minutes) => '$minutes 分';
  @override
  String aboutAnHour(int minutes) => '約 1 時間';
  @override
  String hours(int hours) => '約 $hours 時間';
  @override
  String aDay(int hours) => '約 1 日';
  @override
  String days(int days) => '約 $days 日';
  @override
  String aboutAMonth(int days) => '約 1 か月';
  @override
  String months(int months) => '約 $months か月';
  @override
  String aboutAYear(int year) => '約 1 年';
  @override
  String years(int years) => '約 $years 年';
  @override
  String wordSeparator() => ' ';
}
