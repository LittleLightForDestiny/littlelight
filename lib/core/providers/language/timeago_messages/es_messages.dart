import 'package:timeago/timeago.dart';

class EsMessages implements LookupMessages {
  String prefixAgo() => 'hace';
  String prefixFromNow() => 'dentro de';
  String suffixAgo() => '';
  String suffixFromNow() => '';
  String lessThanOneMinute(int seconds) => 'un momento';
  String aboutAMinute(int minutes) => 'un minuto';
  String minutes(int minutes) => '$minutes minutos';
  String aboutAnHour(int minutes) => 'una hora';
  String hours(int hours) => '$hours horas';
  String aDay(int hours) => 'un día';
  String days(int days) => '$days dias';
  String aboutAMonth(int days) => 'un mes';
  String months(int months) => '$months meses';
  String aboutAYear(int year) => 'un año';
  String years(int years) => '$years años';
  String wordSeparator() => ' ';
}
