import 'package:timeago/timeago.dart';

class DeMessages implements LookupMessages {
  String prefixAgo() => 'vor';
  String prefixFromNow() => 'in';
  String suffixAgo() => '';
  String suffixFromNow() => '';
  String lessThanOneMinute(int seconds) => 'weniger als einer Minute';
  String aboutAMinute(int minutes) => 'einer Minute';
  String minutes(int minutes) => '$minutes Minuten';
  String aboutAnHour(int minutes) => '~1 Stunde';
  String hours(int hours) => '$hours Stunden';
  String aDay(int hours) => '~1 Tag';
  String days(int days) => '$days Tagen';
  String aboutAMonth(int days) => '~1 Monat';
  String months(int months) => '$months Monaten';
  String aboutAYear(int year) => '~1 Jahr';
  String years(int years) => '$years Jahren';
  String wordSeparator() => ' ';
}