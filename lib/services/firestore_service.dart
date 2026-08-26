import 'package:bucky_verse/models/bucket_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get userDoc {
    final currentUid = uid;
    if (currentUid == null) return null;
    return _firestore.collection('users').doc(currentUid);
  }

  CollectionReference<Map<String, dynamic>>? get bucketCollection =>
      userDoc?.collection('bucket');

  /// Add bucket item
  Future<void> addBucketItem(BucketItem item) async {
    try {
      final collection = bucketCollection;
      if (collection == null) return;

      debugPrint("Saving item...");
      debugPrint(item.toMap().toString());

      await collection.doc(item.id).set(item.toMap());

      debugPrint("✅ Saved successfully");
    } catch (e) {
      debugPrint("❌ Firestore Error: $e");
    }
  }

  /// Remove bucket item
  Future<void> removeBucketItem(String id) async {
    try {
      final collection = bucketCollection;
      if (collection == null) return;
      await collection.doc(id).delete();
    } catch (e) {
      debugPrint("❌ Firestore remove error: $e");
    }
  }

  /// Update bucket item
  Future<void> updateBucketItem(BucketItem item) async {
    try {
      final collection = bucketCollection;
      if (collection == null) return;
      await collection.doc(item.id).update(item.toMap());
    } catch (e) {
      debugPrint("❌ Firestore update error: $e");
    }
  }

  /// Load bucket
  Future<List<BucketItem>> loadBucket() async {
    try {
      final collection = bucketCollection;
      if (collection == null) return [];

      debugPrint("===== Loading Bucket =====");

      final snapshot = await collection.get().timeout(
        const Duration(seconds: 5),
      );

      debugPrint("Documents found: ${snapshot.docs.length}");

      return snapshot.docs
          .map((doc) => BucketItem.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint("❌ Firestore loadBucket error: $e");
      return [];
    }
  }
}
