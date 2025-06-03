class TransactionHistory {
  final String id;
  final String transactionId;
  final String action;
  final String description;
  final DateTime timestamp;
  final String? changes;

  TransactionHistory({
    required this.id,
    required this.transactionId,
    required this.action,
    required this.description,
    required this.timestamp,
    this.changes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'action': action,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'changes': changes,
    };
  }

  factory TransactionHistory.fromMap(Map<String, dynamic> map) {
    return TransactionHistory(
      id: map['id'] as String,
      transactionId: map['transactionId'] as String,
      action: map['action'] as String,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      changes: map['changes'] as String?,
    );
  }
} 