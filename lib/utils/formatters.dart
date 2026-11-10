import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'tr_TR',
  symbol: '₺',
  decimalDigits: 2,
);
final _quantity = NumberFormat('#,##0.###', 'tr_TR');
final _percent = NumberFormat('#,##0.00', 'tr_TR');
final _date = DateFormat('d MMMM y', 'tr_TR');
final _time = DateFormat('HH:mm', 'tr_TR');

String formatCurrency(double value) => _currency.format(value);
String formatQuantity(double value) => _quantity.format(value);
String formatPercent(double value) => '%${_percent.format(value)}';
String formatSignedCurrency(double value) =>
    '${value >= 0 ? '+' : '−'}${formatCurrency(value.abs())}';
String formatDate(DateTime date) => _date.format(date);
String formatTime(DateTime date) => _time.format(date);

double? parseDecimal(String input) {
  final normalized = input.trim().replaceAll(' ', '').replaceAll(',', '.');
  return double.tryParse(normalized);
}
