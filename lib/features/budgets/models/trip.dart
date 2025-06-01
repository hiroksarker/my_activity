import 'dart:convert';

class Trip {
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> destinations;
  final double totalBudget;
  final String baseCurrency;
  final String notes;
  final List<String> members;
  final double? budget;
  final List<String>? travelers;

  Trip({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.destinations,
    required this.totalBudget,
    required this.baseCurrency,
    required this.notes,
    required this.members,
    this.budget,
    this.travelers,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'destinations': jsonEncode(destinations),
        'totalBudget': totalBudget,
        'baseCurrency': baseCurrency,
        'notes': notes,
        'members': jsonEncode(members),
        'budget': budget,
        'travelers': jsonEncode(travelers ?? []),
      };

  factory Trip.fromMap(Map<String, dynamic> map) => Trip(
        id: map['id'],
        name: map['name'],
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        destinations: List<String>.from(jsonDecode(map['destinations'])),
        totalBudget: map['totalBudget'],
        baseCurrency: map['baseCurrency'],
        notes: map['notes'] ?? '',
        members: List<String>.from(jsonDecode(map['members'])),
        budget: map['budget'] != null ? (map['budget'] as num).toDouble() : null,
        travelers: map['travelers'] != null
            ? List<String>.from(jsonDecode(map['travelers']))
            : [],
      );

  Trip copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? destinations,
    double? totalBudget,
    String? baseCurrency,
    String? notes,
    List<String>? members,
    double? budget,
    List<String>? travelers,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destinations: destinations ?? this.destinations,
      totalBudget: totalBudget ?? this.totalBudget,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      notes: notes ?? this.notes,
      members: members ?? this.members,
      budget: budget,
      travelers: travelers,
    );
  }
}
