import 'package:cloud_firestore/cloud_firestore.dart';

class LogService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 대여/반납 로그를 기록하는 함수
  static Future<void> addRentalLog({
    required String userId,
    required String stationId,
    required String action, // 'rent' 또는 'return'
  }) async {
    try {
      await _db.collection('rental_logs').add({
        'userId': userId,
        'stationId': stationId,
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('addRentalLog 에러: $e');
    }
  }
}
