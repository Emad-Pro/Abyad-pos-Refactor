import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: (int.tryParse(newValue.text) ?? 0).formatNumber(),
    );
  }
}

extension FormatAmount on double? {
  /// Format with $ sign and 2 decimal point
  ///
  /// - [ print(15.3.formatAmount()); ] output: $15.30
  ///
  /// - [ print(15.formatAmount()); ] output: $15.00
  String formatAmount() {
    NumberFormat numberFormat = NumberFormat.simpleCurrency(name: 'USD');

    if (this == null) {
      return numberFormat.format(0);
    }
    return numberFormat.format(this);
  }
}

extension FormatNumber on int {
  /// Format int with comma separated value
  /// - [ print(1503.formatNumber()); ] output: 1,530
  /// - [ print(15032003.formatNumber()); ] output: 15,032,003
  String formatNumber() {
    return NumberFormat().format(this);
  }
}
