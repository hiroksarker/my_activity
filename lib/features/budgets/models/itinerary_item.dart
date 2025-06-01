import 'package:flutter/material.dart';

class ItineraryItem {
  final int id;
  final int tripId;
  final String activity;  // Main activity name
  final String date;
  final String time;      // Time in 12-hour format (e.g., "09:30 AM")
  final String notes;     // Details for this time slot
  final int sortOrder;    // For ordering within the same activity

  ItineraryItem({
    required this.id,
    required this.tripId,
    required this.activity,
    required this.date,
    required this.time,
    required this.notes,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'activity': activity,
      'date': date,
      'time': time,
      'notes': notes,
      'sortOrder': sortOrder,
    };
  }

  factory ItineraryItem.fromMap(Map<String, dynamic> map) {
    return ItineraryItem(
      id: map['id'],
      tripId: map['tripId'],
      activity: map['activity'],
      date: map['date'],
      time: map['time'],
      notes: map['notes'],
      sortOrder: map['sortOrder'] ?? 0,
    );
  }

  ItineraryItem copyWith({
    int? id,
    int? tripId,
    String? activity,
    String? date,
    String? time,
    String? notes,
    int? sortOrder,
  }) {
    return ItineraryItem(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      activity: activity ?? this.activity,
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
