import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore 관련 모든 데이터 관리 기능
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================
  // 🔹 Umbrella 데이터 관리
  // ==========================

  /// 우산 대여 상태로 설정
  static Future<void> rentUmbrella(String umbrellaId, String userId) async {
    await _db.collection('umbrellas').doc(umbrellaId).set({
      'isRented': true,
      'renterId': userId,
      'rentedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 우산 반납 처리
  static Future<void> returnUmbrella(String umbrellaId) async {
    await _db.collection('umbrellas').doc(umbrellaId).set({
      'isRented': false,
      'renterId': FieldValue.delete(),
      'rentedAt': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  /// 우산 정보 조회
  static Future<DocumentSnapshot> getUmbrella(String umbrellaId) async {
    return await _db.collection('umbrellas').doc(umbrellaId).get();
  }

  // ==========================
  // 🔹 사용자 대여 상태 관리
  // ==========================

  /// 사용자의 대여 상태를 "rented"로 설정하고 우산 ID 기록
  static Future<void> rentUmbrellaForUser(String umbrellaId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('rentals').doc(user.uid).set({
      'userId': user.uid,
      'umbrellaId': umbrellaId,
      'status': 'rented',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 사용자의 대여 상태를 "returned"로 업데이트
  static Future<void> returnUmbrellaForUser() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('rentals').doc(user.uid).update({
      'status': 'returned',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 사용자의 현재 대여 상태 조회 (rented / returned / null)
  static Future<String?> getRentalStatus() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('rentals').doc(user.uid).get();
    return doc.exists ? doc['status'] : null;
  }

  /// 사용자의 rental 문서 자체를 반환 (umbrellaId 조회용)
  static Future<DocumentSnapshot<Map<String, dynamic>>?> getRentalDoc(
    String userId,
  ) async {
    try {
      final doc = await _db.collection('rentals').doc(userId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('getRentalDoc 에러: $e');
      return null;
    }
  }

  // ==========================
  // 🔹 대여/반납 로그 기록
  // ==========================

  /// 대여/반납 로그 기록 (rent or return)
  static Future<void> addRentalLog({
    required String userId,
    required String umbrellaId,
    required String action,
  }) async {
    await _db.collection('rental_logs').add({
      'userId': userId,
      'umbrellaId': umbrellaId,
      'action': action, // 'rent' or 'return'
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
