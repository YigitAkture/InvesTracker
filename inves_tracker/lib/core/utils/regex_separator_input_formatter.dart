import 'package:flutter/services.dart';

class RegexSeparatorInputFormatter extends TextInputFormatter {
  final bool allowDecimal;
  final String locale;

  RegexSeparatorInputFormatter({
    this.allowDecimal = true,
    this.locale = 'en_US',
  });

  String get _thousandSep => locale == 'tr_TR' ? '.' : ',';
  String get _decimalSep  => locale == 'tr_TR' ? ',' : '.';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove thousand separators, normalize decimal sep to '.' for internal use
    String raw = newValue.text.replaceAll(_thousandSep, '');
    if (allowDecimal) {
      raw = raw.replaceAll(_decimalSep, '.');
    } else {
      raw = raw.replaceAll(_decimalSep, '');
    }

    final regex = allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'^\d*$');
    if (!regex.hasMatch(raw)) return oldValue;

    if (raw.isEmpty) return newValue.copyWith(text: '');

    final parts   = raw.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : null;

    String formatted = intPart.isNotEmpty ? _addSeparators(intPart) : '';

    if (fracPart != null) {
      formatted = '$formatted$_decimalSep$fracPart';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addSeparators(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(_thousandSep);
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}