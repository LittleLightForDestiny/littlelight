import 'package:timeago/timeago.dart';

class PtBrMessages implements LookupMessages {
  String prefixAgo() => 'Há';
  String prefixFromNow() => 'em';
  String suffixAgo() => 'atrás';
  String suffixFromNow() => '';
  String lessThanOneMinute(int seconds) => 'menos de um minuto';
  String aboutAMinute(int minutes) => 'um minuto';
  String minutes(int minutes) => '$minutes minutos';
  String aboutAnHour(int minutes) => 'uma hora';
  String hours(int hours) => '$hours horas';
  String aDay(int hours) => 'um dia';
  String days(int days) => '$days dias';
  String aboutAMonth(int days) => 'um mês';
  String months(int months) => '$months meses';
  String aboutAYear(int year) => 'um ano';
  String years(int years) => '$years anos';
  String wordSeparator() => ' ';
}