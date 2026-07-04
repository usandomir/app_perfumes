class CurrencyFormatter {
  static const String ars = 'ARS';
  static const String usd = 'USD';
  static const String eur = 'EUR';

  static const List<String> labels = ['ARS (\$)', 'USD (U\$S)', 'EUR (€)'];

  static const Map<String, double> _ratesFromUsd = {
    ars: 1000,
    usd: 1,
    eur: 0.92,
  };

  static String codeFromLabel(String label) {
    if (label.startsWith(ars)) return ars;
    if (label.startsWith(eur)) return eur;
    return usd;
  }

  static String labelFromCode(String code) {
    return labels.firstWhere(
      (label) => label.startsWith(code),
      orElse: () => labels[1],
    );
  }

  static String formatUsd(double precioUsd, String moneda) {
    final code = codeFromLabel(moneda);
    final converted = precioUsd * (_ratesFromUsd[code] ?? 1);

    switch (code) {
      case ars:
        return '\$ ${converted.toStringAsFixed(0)} ARS';
      case eur:
        return '€ ${converted.toStringAsFixed(2)}';
      default:
        return 'U\$S ${converted.toStringAsFixed(2)}';
    }
  }
}
