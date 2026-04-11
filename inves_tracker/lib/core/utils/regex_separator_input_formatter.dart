import 'package:flutter/services.dart';

class RegexSeparatorInputFormatter extends TextInputFormatter {
  final bool allowDecimal;

  RegexSeparatorInputFormatter({this.allowDecimal = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip everything except digits (and decimal point if allowed)
    String raw = newValue.text.replaceAll(',', '');
    if (!allowDecimal) {
      raw = raw.replaceAll('.', '');
    }

    // Validate: only digits and at most one decimal point
    final regex = allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'^\d*$');
    if (!regex.hasMatch(raw)) return oldValue;

    if (raw.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Split integer and fractional parts
    final parts = raw.split('.');
    final intPart = parts[0];
    final fracPart = parts.length > 1 ? parts[1] : null;

    // Format the integer part with commas
    String formatted = '';
    if (intPart.isNotEmpty) {
      final intValue = int.tryParse(intPart);
      if (intValue != null) {
        // Insert commas manually (avoids importing intl just for this)
        formatted = _addCommas(intPart);
      } else {
        formatted = intPart;
      }
    }

    // Re-attach fractional part (unformatted — user is still typing it)
    if (fracPart != null) {
      formatted = '$formatted.$fracPart';
    }

    return TextEditingValue(
      text: formatted,
      // Keep cursor at end to avoid jump-back issues
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String digits) {
    // Walk right-to-left inserting commas every 3 digits
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}