import 'package:uuid/uuid.dart';

enum ActivityType {
  task,
  expense,
}

enum TransactionType {
  debit,  // Money spent (expense)
  credit, // Money received (income)
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  final double amount;
  final String category;
  final TaskStatus status;
  final TransactionType? transactionType;  // Only for expense type activities

  static final _idPattern = RegExp(r'^[a-z0-9]+$');

  Activity({
    String? id,
    required this.title,
    required this.description,
    DateTime? timestamp,
    required this.type,
    this.amount = 0.0,
    this.category = 'general',
    TaskStatus? status,
    this.transactionType,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now(),
       status = status ?? (type == ActivityType.task ? TaskStatus.pending : TaskStatus.completed),
       assert(
         type == ActivityType.task || transactionType != null,
         'Transaction type must be specified for expense activities',
       );

  static String _generateId() {
    // Generate a UUID and convert to lowercase alphanumeric
    final uuid = const Uuid().v4();
    // Take first 15 chars and ensure they're lowercase alphanumeric
    final baseId = uuid.replaceAll(RegExp(r'[^a-z0-9]'), '').toLowerCase().substring(0, 15);
    return baseId;
  }

  static String _validateId(String id) {
    if (!_idPattern.hasMatch(id)) {
      throw ArgumentError('Activity ID must contain only lowercase alphanumeric characters');
    }
    if (id.length > 15) {
      throw ArgumentError('Activity ID must not exceed 15 characters');
    }
    return id;
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ActivityType.task,
      ),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      transactionType: json['transactionType'] != null
          ? TransactionType.values.firstWhere(
              (e) => e.toString().split('.').last == json['transactionType'],
              orElse: () => TransactionType.debit,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'amount': amount,
      'category': category,
      'status': status.toString().split('.').last,
      if (transactionType != null)
        'transactionType': transactionType.toString().split('.').last,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      timestamp: map['timestamp'] is DateTime 
          ? map['timestamp'] as DateTime 
          : DateTime.parse(map['timestamp'] as String),
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ActivityType.task,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => TaskStatus.pending,
      ),
      transactionType: map['transactionType'] != null
          ? TransactionType.values.firstWhere(
              (e) => e.toString().split('.').last == map['transactionType'],
              orElse: () => TransactionType.debit,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'amount': amount,
      'category': category,
      'status': status.toString().split('.').last,
      'transactionType': transactionType?.toString().split('.').last,
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    ActivityType? type,
    double? amount,
    String? category,
    TaskStatus? status,
    TransactionType? transactionType,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      status: status ?? this.status,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.timestamp == timestamp &&
        other.type == type &&
        other.amount == amount &&
        other.category == category &&
        other.status == status &&
        other.transactionType == transactionType;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      timestamp,
      type,
      amount,
      category,
      status,
      transactionType,
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, type: $type, status: $status)';
  }
} 