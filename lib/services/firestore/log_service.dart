import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 대여/반납 로그 기록
  static Future<void> addRentalLog({
    required String userId,
    required String stationId,
    required String action, // 예: 'rent', 'return'
  }) async {
    try {
      final user = _auth.currentUser;
      final userType = _getUserType(user);

      await _db.collection('rental_logs').add({
        'userId': userId,
        'userType': userType, // 'anonymous', 'google', 'kakao' 등
        'stationId': stationId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('addRentalLog 에러: $e');
    }
  }

  /// 사용자 로그인 방식에 따라 userType 리턴
  static String _getUserType(User? user) {
    if (user == null) return 'unknown';
    if (user.isAnonymous) return 'anonymous';
    final providerId =
        user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : 'unknown';
    switch (providerId) {
      case 'google.com':
        return 'google';
      case 'kakao.com':
        return 'kakao'; // 직접 구현한 경우, 백엔드와 연동 시 명시적으로 처리 필요
      case 'password':
        return 'email';
      default:
        return providerId;
    }
  }
}
