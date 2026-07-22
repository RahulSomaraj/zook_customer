/// Formats an integer AED amount with thousands separators, e.g. 1800 -> "1,800".
String formatAmount(num value) {
  final str = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
    buffer.write(str[i]);
  }
  return buffer.toString();
}
