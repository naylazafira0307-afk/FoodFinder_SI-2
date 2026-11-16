import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 135000 -> "135.000"
String ribuan(num v) {
  final s = v.round().abs().toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

/// 135000 -> "Rp135.000"
String rp(num v) => 'Rp${ribuan(v)}';

/// "135.000" -> 135000
int angka(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

String two(int n) => n.toString().padLeft(2, '0');

/// Tanggal + jam, contoh: 16/11/2026 13:30
String fw(DateTime d) =>
    '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';

String jam(DateTime d) => '${two(d.hour)}:${two(d.minute)}';

void snack(BuildContext context, String pesan) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(milliseconds: 2200),
      ),
    );
}

/// Format angka otomatis jadi ribuan saat diketik (untuk input harga).
class RibuanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > 12) return oldValue;
    final t = digits.isEmpty ? '' : ribuan(int.parse(digits));
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}
