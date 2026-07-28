import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service wrapper for Cloud Firestore database operations.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection reference for 'users'.
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  /// Create or set user profile document for [uid].
  Future<void> createUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await usersCollection.doc(uid).set({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService createUserProfile Error: $e');
      rethrow;
    }
  }

  /// Get user profile document snapshot for [uid].
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) async {
    try {
      return await usersCollection.doc(uid).get();
    } catch (e) {
      debugPrint('FirestoreService getUserProfile Error: $e');
      rethrow;
    }
  }

  /// Update user profile document for [uid].
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await usersCollection.doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirestoreService updateUserProfile Error: $e');
      rethrow;
    }
  }

  /// Stream user profile document changes for [uid].
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(String uid) {
    return usersCollection.doc(uid).snapshots();
  }
}
