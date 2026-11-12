import 'package:altin_hesaplama/utils/formatters.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Türkçe ondalık ve binlik sayıları doğru çözer', () {
    setFormattingLocale(const Locale('tr'));
    expect(parseDecimal('1.000,50'), 1000.50);
    expect(parseDecimal('1500.00'), 1500);
    expect(parseDecimal('1.5'), 1.5);
    expect(parseDecimal('1.000'), 1000);
  });

  test('İngilizce sayı biçimini doğru çözer', () {
    setFormattingLocale(const Locale('en'));
    expect(parseDecimal('1,000.50'), 1000.50);
    expect(parseDecimal('1500.00'), 1500);
    setFormattingLocale(const Locale('tr'));
  });
}
