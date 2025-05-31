import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget.dart';
import '../models/receipt.dart';
import '../models/income.dart';

class FamilyService {
  static final FamilyService _instance = FamilyService._internal();
  factory FamilyService() => _instance;
  FamilyService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createFamilyGroup({
    required String name,
    required List<String> memberEmails,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Create family group document
      final familyRef = await _firestore.collection('family_groups').add({
        'name': name,
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'members': [userId],
        'memberEmails': memberEmails,
        'status': 'pending', // pending, active, archived
      });

      // Send invitations to members
      for (final email in memberEmails) {
        await _sendFamilyInvitation(
          familyGroupId: familyRef.id,
          email: email,
        );
      }
    } catch (e) {
      throw Exception('Failed to create family group: $e');
    }
  }

  Future<void> acceptFamilyInvitation(String familyGroupId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) throw Exception('User email not found');

      // Update family group members
      await _firestore.collection('family_groups').doc(familyGroupId).update({
        'members': FieldValue.arrayUnion([userId]),
        'memberEmails': FieldValue.arrayUnion([userEmail]),
        'status': 'active',
      });

      // Remove invitation
      await _firestore
          .collection('family_invitations')
          .where('familyGroupId', isEqualTo: familyGroupId)
          .where('email', isEqualTo: userEmail)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
    } catch (e) {
      throw Exception('Failed to accept family invitation: $e');
    }
  }

  Future<void> shareBudget({
    required String familyGroupId,
    required Budget budget,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user is a member of the family group
      final familyGroup = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .get();

      if (!familyGroup.exists) {
        throw Exception('Family group not found');
      }

      final members = List<String>.from(familyGroup.data()?['members'] ?? []);
      if (!members.contains(userId)) {
        throw Exception('User is not a member of this family group');
      }

      // Share budget with family group
      await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .collection('shared_budgets')
          .add({
        'budgetId': budget.id,
        'sharedBy': userId,
        'sharedAt': FieldValue.serverTimestamp(),
        'budgetData': budget.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to share budget: $e');
    }
  }

  Future<void> shareReceipt({
    required String familyGroupId,
    required Receipt receipt,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user is a member of the family group
      final familyGroup = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .get();

      if (!familyGroup.exists) {
        throw Exception('Family group not found');
      }

      final members = List<String>.from(familyGroup.data()?['members'] ?? []);
      if (!members.contains(userId)) {
        throw Exception('User is not a member of this family group');
      }

      // Share receipt with family group
      await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .collection('shared_receipts')
          .add({
        'receiptId': receipt.id,
        'sharedBy': userId,
        'sharedAt': FieldValue.serverTimestamp(),
        'receiptData': receipt.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to share receipt: $e');
    }
  }

  Future<void> shareIncome({
    required String familyGroupId,
    required Income income,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user is a member of the family group
      final familyGroup = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .get();

      if (!familyGroup.exists) {
        throw Exception('Family group not found');
      }

      final members = List<String>.from(familyGroup.data()?['members'] ?? []);
      if (!members.contains(userId)) {
        throw Exception('User is not a member of this family group');
      }

      // Share income with family group
      await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .collection('shared_incomes')
          .add({
        'incomeId': income.id,
        'sharedBy': userId,
        'sharedAt': FieldValue.serverTimestamp(),
        'incomeData': income.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to share income: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFamilyGroups() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) throw Exception('User email not found');

      // Get family groups where user is a member
      final snapshot = await _firestore
          .collection('family_groups')
          .where('memberEmails', arrayContains: userEmail)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'createdBy': data['createdBy'],
          'createdAt': data['createdAt'],
          'members': data['members'],
          'memberEmails': data['memberEmails'],
          'status': data['status'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get family groups: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSharedBudgets(String familyGroupId) async {
    try {
      final snapshot = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .collection('shared_budgets')
          .orderBy('sharedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'budgetId': data['budgetId'],
          'sharedBy': data['sharedBy'],
          'sharedAt': data['sharedAt'],
          'budgetData': data['budgetData'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get shared budgets: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSharedReceipts(String familyGroupId) async {
    try {
      final snapshot = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .collection('shared_receipts')
          .orderBy('sharedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'receiptId': data['receiptId'],
          'sharedBy': data['sharedBy'],
          'sharedAt': data['sharedAt'],
          'receiptData': data['receiptData'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get shared receipts: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSharedIncomes(String familyGroupId) async {
    try {
      final snapshot = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .collection('shared_incomes')
          .orderBy('sharedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'incomeId': data['incomeId'],
          'sharedBy': data['sharedBy'],
          'sharedAt': data['sharedAt'],
          'incomeData': data['incomeData'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get shared incomes: $e');
    }
  }

  Future<void> _sendFamilyInvitation({
    required String familyGroupId,
    required String email,
  }) async {
    try {
      await _firestore.collection('family_invitations').add({
        'familyGroupId': familyGroupId,
        'email': email,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, accepted, rejected
      });

      // TODO: Send email notification to the invited user
      // This would typically be handled by a Cloud Function
    } catch (e) {
      throw Exception('Failed to send family invitation: $e');
    }
  }

  Future<void> leaveFamilyGroup(String familyGroupId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final userEmail = _auth.currentUser?.email;
      if (userEmail == null) throw Exception('User email not found');

      // Remove user from family group
      await _firestore.collection('family_groups').doc(familyGroupId).update({
        'members': FieldValue.arrayRemove([userId]),
        'memberEmails': FieldValue.arrayRemove([userEmail]),
      });

      // If no members left, archive the family group
      final familyGroup = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .get();

      final members = List<String>.from(familyGroup.data()?['members'] ?? []);
      if (members.isEmpty) {
        await _firestore
            .collection('family_groups')
            .doc(familyGroupId)
            .update({'status': 'archived'});
      }
    } catch (e) {
      throw Exception('Failed to leave family group: $e');
    }
  }

  Future<void> updateFamilyGroupSettings({
    required String familyGroupId,
    required Map<String, dynamic> settings,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Verify user is the creator of the family group
      final familyGroup = await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .get();

      if (!familyGroup.exists) {
        throw Exception('Family group not found');
      }

      if (familyGroup.data()?['createdBy'] != userId) {
        throw Exception('Only the creator can update family group settings');
      }

      // Update family group settings
      await _firestore
          .collection('family_groups')
          .doc(familyGroupId)
          .update(settings);
    } catch (e) {
      throw Exception('Failed to update family group settings: $e');
    }
  }
} 