import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 사용자가 우산을 대여했을 때 호출 (이용권 차감 포함)
  static Future<void> rentForUser(String stationId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("로그인된 사용자가 없습니다.");

    final passRef = _db.collection('passes').doc(user.uid);
    final passDoc = await passRef.get();

    if (!passDoc.exists) {
      print("[rentForUser] 이용권 없음");
      throw Exception("이용권이 존재하지 않습니다.");
    }

    final data = passDoc.data();
    final int remaining = data?['remaining'] ?? 0;
    print("[rentForUser] 남은 이용권: $remaining");

    if (remaining <= 0) {
      throw Exception("남은 이용권이 없습니다.");
    }

    await passRef.update({
      'remaining': remaining - 1,
      'lastUsed': DateTime.now(),
    });

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

  /// 현재 사용자의 대여 상태 반환 (rented, returned, null)
  static Future<String?> getRentalStatus() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('rentals').doc(user.uid).get();
    return doc.exists ? doc['status'] : null;
  }

  /// 현재 사용자의 rental 문서 전체 반환
  static Future<DocumentSnapshot<Map<String, dynamic>>?> getRentalDoc() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _db.collection('rentals').doc(user.uid).get();
      return doc.exists ? doc : null;
    } catch (e) {
      print('[getRentalDoc] 에러: $e');
      return null;
    }
  }

  /// 현재 사용자가 유효한 이용권을 보유하고 있는지 확인
  static Future<bool> hasValidPass(String userId) async {
    try {
      final doc = await _db.collection('passes').doc(userId).get();
      if (!doc.exists) return false;
      final data = doc.data();
      final int remaining = data?['remaining'] ?? 0;
      print("[hasValidPass] remaining: $remaining");
      return remaining > 0;
    } catch (e) {
      print('[hasValidPass] 에러: $e');
      return false;
    }
  }

  /// 현재 사용자의 남은 이용권 횟수 반환
  static Future<int> getRemainingPassCount(String userId) async {
    try {
      final doc = await _db.collection('passes').doc(userId).get();
      return doc.exists ? (doc.data()?['remaining'] ?? 0) : 0;
    } catch (e) {
      print('[getRemainingPassCount] 에러: $e');
      return 0;
    }
  }

  /// 테스트용 이용권 발급
  static Future<void> issueTestPass() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("로그인된 사용자가 없습니다.");

    final passRef = _db.collection('passes').doc(user.uid);
    final doc = await passRef.get();

    if (doc.exists) {
      final current = doc.data()?['remaining'] ?? 0;
      await passRef.update({'remaining': current + 1});
    } else {
      await passRef.set({'remaining': 1, 'lastUsed': null});
    }
  }
}
