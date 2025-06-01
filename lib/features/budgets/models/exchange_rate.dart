class ExchangeRate {
  final int? id;
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime date;

  ExchangeRate({
    this.id,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'rate': rate,
        'date': date.toIso8601String(),
      };

  factory ExchangeRate.fromMap(Map<String, dynamic> map) => ExchangeRate(
        id: map['id'],
        fromCurrency: map['fromCurrency'],
        toCurrency: map['toCurrency'],
        rate: map['rate'],
        date: DateTime.parse(map['date']),
      );
}
