import 'package:currency_formatter/currency_formatter.dart';

CurrencyFormat dopSettings = CurrencyFormat(
  symbol: 'RD',
  symbolSide: SymbolSide.left,
  thousandSeparator: ',',
  decimalSeparator: '.',
  symbolSeparator: ' \$',
);

CurrencyFormat usSettings = CurrencyFormat(
  symbol: 'US',
  symbolSide: SymbolSide.left,
  thousandSeparator: ',',
  decimalSeparator: '.',
  symbolSeparator: ' \$',
);
CurrencyFormat defaultSettings = CurrencyFormat(
  symbol: '',
  symbolSide: SymbolSide.left,
  thousandSeparator: ',',
  decimalSeparator: '.',
  symbolSeparator: ' \$',
);

extension DopFormatterExtension on double {
  toDop() {
    return CurrencyFormatter.format(this, dopSettings, enforceDecimals: true);
  }

  toUS() {
    return CurrencyFormatter.format(this, usSettings, enforceDecimals: true);
  }

  toCoin() {
    return CurrencyFormatter.format(this, defaultSettings, enforceDecimals: true);
  }
}
