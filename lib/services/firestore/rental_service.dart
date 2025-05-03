import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 사용자가 우산을 대여했을 때 호출
  static Future<void> rentForUser(String stationId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("로그인된 사용자가 없습니다.");

    await _db.collection('rentals').doc(user.uid).set({
      'userId': user.uid,
      'stationId': stationId,
      'status': 'rented',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 사용자가 우산을 반납했을 때 호출
  static Future<void> returnForUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("로그인된 사용자가 없습니다.");

    await _db.collection('rentals').doc(user.uid).update({
      'status': 'returned',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// 현재 사용자의 대여 상태 (rented / returned / null) 반환
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

  /// 현재 사용자의 rental 문서 전체 반환
  static Future<DocumentSnapshot<Map<String, dynamic>>?> getRentalDoc() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('rentals').doc(user.uid).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('getRentalDoc 에러: $e');
      return null;
    }
  }
}
