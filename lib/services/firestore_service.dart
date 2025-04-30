import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ======================
  // Umbrella 관리
  // ======================

  static Future<void> rentUmbrella(String umbrellaId, String userId) async {
    await _db.collection('umbrellas').doc(umbrellaId).set({
      'isRented': true,
      'renterId': userId,
      'rentedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> returnUmbrella(String umbrellaId) async {
    await _db.collection('umbrellas').doc(umbrellaId).set({
      'isRented': false,
      'renterId': FieldValue.delete(), // 삭제 처리
      'rentedAt': FieldValue.delete(), // 삭제 처리
    }, SetOptions(merge: true));
  }

  static Future<DocumentSnapshot> getUmbrella(String umbrellaId) async {
    return await _db.collection('umbrellas').doc(umbrellaId).get();
  }

  // ======================
  // User 대여 상태 관리
  // ======================

  static Future<void> rentUmbrellaForUser(String umbrellaId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('rentals').doc(user.uid).set({
      'userId': user.uid,
      'umbrellaId': umbrellaId, // ✅ 이 필드가 없어서 오류 발생했던 거야!
      'status': 'rented',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> returnUmbrellaForUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('rentals').doc(user.uid).update({
      'status': 'returned',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<String?> getRentalStatus() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('rentals').doc(user.uid).get();
    if (doc.exists) {
      return doc['status'];
    } else {
      return null;
    }
  }

  static Future<void> addRentalLog({
    required String userId,
    required String umbrellaId,
    required String action, // 'rent' 또는 'return'
  }) async {
    await _db.collection('rental_logs').add({
      'userId': userId,
      'umbrellaId': umbrellaId,
      'action': action,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> getRentalDoc(
    String userId,
  ) async {
    try {
      final doc = await _db.collection('rentals').doc(userId).get();
      if (doc.exists) {
        return doc;
      } else {
        return null;
      }
    } catch (e) {
      print('getRentalDoc 에러: $e');
      return null;
    }
  }
}
