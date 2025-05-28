import 'package:cloud_firestore/cloud_firestore.dart';

class StationService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 대여소에서 우산 대여: 수량 1 감소
  static Future<void> rentFromStation(String stationId) async {
    final docRef = _db.collection('stations').doc(stationId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      print('[rentFromStation] stationId: $stationId');
      print('[rentFromStation] station exists: ${snapshot.exists}');
      print('[rentFromStation] station data: ${snapshot.data()}');

      if (!snapshot.exists) {
        throw Exception("존재하지 않는 대여소입니다: $stationId");
      }

      final currentCount = snapshot.data()?['currentCount'] ?? 0;
      if (currentCount <= 0) {
        throw Exception("대여 가능한 우산이 없습니다.");
      }

      transaction.update(docRef, {'currentCount': currentCount - 1});
    });
  }

  /// 대여소에 우산 반납: 수량 1 증가
  static Future<void> returnToStation(String stationId) async {
    final docRef = _db.collection('stations').doc(stationId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      print('[returnToStation] stationId: $stationId');
      print('[returnToStation] station exists: ${snapshot.exists}');
      print('[returnToStation] station data: ${snapshot.data()}');

      if (!snapshot.exists) {
        throw Exception("존재하지 않는 대여소입니다: $stationId");
      }

      final currentCount = snapshot.data()?['currentCount'] ?? 0;
      final capacity = snapshot.data()?['capacity'] ?? 0;

      if (currentCount >= capacity) {
        throw Exception("수용 가능한 우산 수량을 초과했습니다.");
      }

      transaction.update(docRef, {'currentCount': currentCount + 1});
    });
  }

  /// 모든 대여소 목록 가져오기 (지도 마커용)
  static Future<List<Map<String, dynamic>>> getAllStations() async {
    final snapshot = await _db.collection('stations').get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}
