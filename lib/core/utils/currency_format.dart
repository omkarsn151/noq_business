/// '₹499' / '₹499.50' / 'USD 12.00' - amounts arrive as decimal strings so the
/// trailing '.00' is dropped rather than reformatted as a double.
String formatAmount(String value, String currencyCode) {
  var amount = value.trim();
  if (amount.isEmpty) amount = '0';
  if (amount.endsWith('.00')) {
    amount = amount.substring(0, amount.length - 3);
  }
  return currencyCode == 'INR' ? '₹$amount' : '$currencyCode $amount';
}
