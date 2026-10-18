class PriceFormatter {
  static String format(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}
