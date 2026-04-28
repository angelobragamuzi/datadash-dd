import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final NumberFormat _numberFormat = NumberFormat('#,##0.##', 'pt_BR');

  static String dateTime(DateTime date) => _dateTimeFormat.format(date);

  static String number(num value) => _numberFormat.format(value);
}
