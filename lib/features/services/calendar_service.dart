import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget.dart';
import '../models/receipt.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Calendar events types
  static const String EVENT_TYPE_BUDGET_START = 'budget_start';
  static const String EVENT_TYPE_BUDGET_END = 'budget_end';
  static const String EVENT_TYPE_RECEIPT = 'receipt';
  static const String EVENT_TYPE_MILESTONE = 'milestone';
  static const String EVENT_TYPE_REMINDER = 'reminder';

  Future<void> addEvent({
    required String title,
    required DateTime date,
    required String type,
    String? description,
    Map<String, dynamic>? metadata,
    String? color,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calendar_events')
          .add({
        'title': title,
        'date': Timestamp.fromDate(date),
        'type': type,
        'description': description,
        'metadata': metadata,
        'color': color,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add calendar event: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEventsForDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('calendar_events')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'date': (data['date'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get calendar events: $e');
    }
  }

  Future<void> syncBudgetEvents(Budget budget) async {
    try {
      // Add budget start event
      await addEvent(
        title: '${budget.name} Budget Start',
        date: budget.startDate,
        type: EVENT_TYPE_BUDGET_START,
        description: 'Budget period begins',
        metadata: {'budgetId': budget.id},
        color: '#4CAF50', // Green
      );

      // Add budget end event
      await addEvent(
        title: '${budget.name} Budget End',
        date: budget.endDate,
        type: EVENT_TYPE_BUDGET_END,
        description: 'Budget period ends',
        metadata: {'budgetId': budget.id},
        color: '#F44336', // Red
      );
    } catch (e) {
      throw Exception('Failed to sync budget events: $e');
    }
  }

  Future<void> syncReceiptEvent(Receipt receipt) async {
    try {
      await addEvent(
        title: '${receipt.merchantName ?? 'Receipt'} - ${receipt.formattedAmount}',
        date: receipt.date,
        type: EVENT_TYPE_RECEIPT,
        description: receipt.description,
        metadata: {
          'receiptId': receipt.id,
          'amount': receipt.amount,
          'category': receipt.category,
        },
        color: receipt.status == 'verified' ? '#2196F3' : '#FFC107', // Blue or Yellow
      );
    } catch (e) {
      throw Exception('Failed to sync receipt event: $e');
    }
  }

  Future<void> addFinancialMilestone({
    required String title,
    required DateTime date,
    required double targetAmount,
    String? description,
  }) async {
    try {
      await addEvent(
        title: title,
        date: date,
        type: EVENT_TYPE_MILESTONE,
        description: description,
        metadata: {'targetAmount': targetAmount},
        color: '#9C27B0', // Purple
      );
    } catch (e) {
      throw Exception('Failed to add financial milestone: $e');
    }
  }

  Future<void> addReminder({
    required String title,
    required DateTime date,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await addEvent(
        title: title,
        date: date,
        type: EVENT_TYPE_REMINDER,
        description: description,
        metadata: metadata,
        color: '#FF9800', // Orange
      );
    } catch (e) {
      throw Exception('Failed to add reminder: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calendar_events')
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete calendar event: $e');
    }
  }

  Future<void> updateEvent({
    required String eventId,
    String? title,
    DateTime? date,
    String? description,
    Map<String, dynamic>? metadata,
    String? color,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (date != null) updates['date'] = Timestamp.fromDate(date);
      if (description != null) updates['description'] = description;
      if (metadata != null) updates['metadata'] = metadata;
      if (color != null) updates['color'] = color;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calendar_events')
          .doc(eventId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update calendar event: $e');
    }
  }
} 