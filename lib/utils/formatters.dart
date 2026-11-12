import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

String _locale = 'tr_TR';

void setFormattingLocale(Locale locale) {
  _locale = locale.languageCode == 'en' ? 'en_US' : 'tr_TR';
}

String formatCurrency(double value) => NumberFormat.currency(
      locale: _locale,
      symbol: '₺',
      decimalDigits: 2,
    ).format(value);

String formatQuantity(double value) =>
    NumberFormat('#,##0.###', _locale).format(value);

String formatPercent(double value) {
  final formatted = NumberFormat('#,##0.00', _locale).format(value);
  return _locale == 'en_US' ? '$formatted%' : '%$formatted';
}

String formatSignedCurrency(double value) =>
    '${value >= 0 ? '+' : '−'}${formatCurrency(value.abs())}';

String formatDate(DateTime date) =>
    DateFormat('d MMMM y', _locale).format(date);

String formatTime(DateTime date) => DateFormat('HH:mm', _locale).format(date);

double? parseDecimal(String input) {
  var normalized = input.trim().replaceAll(' ', '');
  if (_locale == 'en_US') {
    normalized = normalized.replaceAll(',', '');
  } else if (normalized.contains(',')) {
    normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
  } else {
    final parts = normalized.split('.');
    if (parts.length > 2 ||
        (parts.length == 2 && parts.last.length == 3)) {
      normalized = normalized.replaceAll('.', '');
    }
  }
  return double.tryParse(normalized);
}
