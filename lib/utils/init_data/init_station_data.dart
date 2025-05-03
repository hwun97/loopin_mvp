import 'package:cloud_firestore/cloud_firestore.dart';

class StationInitializer {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> initStations() async {
    final stations = [
      {'id': 'station_01', 'capacity': 10, 'currentCount': 7},
      {'id': 'station_02', 'capacity': 12, 'currentCount': 4},
      {'id': 'station_03', 'capacity': 8, 'currentCount': 0},
    ];

    for (final station in stations) {
      await _db.collection('stations').doc(station['id'] as String).set({
        'capacity': station['capacity'],
        'currentCount': station['currentCount'],
      });
    }

    print('✅ 대여소 초기화 완료');
  }
}
