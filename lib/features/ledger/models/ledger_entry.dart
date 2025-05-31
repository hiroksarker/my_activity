class LedgerEntry {
  final String id;
  final DateTime date;
  final String description;
  final double debit;
  final double credit;
  final String account;
  final String category;
  final String? notes;

  LedgerEntry({
    required this.id,
    required this.date,
    required this.description,
    required this.debit,
    required this.credit,
    required this.account,
    required this.category,
    this.notes,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: json['id'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        debit: (json['debit'] as num).toDouble(),
        credit: (json['credit'] as num).toDouble(),
        account: json['account'],
        category: json['category'],
        notes: json['notes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'description': description,
        'debit': debit,
        'credit': credit,
        'account': account,
        'category': category,
        'notes': notes,
      };
}
