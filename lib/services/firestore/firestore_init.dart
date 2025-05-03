import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInit {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 대여소 초기화용 함수 (한 번만 실행)
  static Future<void> initializeStations() async {
    final stations = [
      {
        'id': 'station_01',
        'name': '건국대학교 정문',
        'capacity': 10,
        'currentCount': 5,
      },
      {
        'id': 'station_02',
        'name': '건국대학교 후문',
        'capacity': 8,
        'currentCount': 3,
      },
      {
        'id': 'station_03',
        'name': '지하철 건대입구역 2번 출구',
        'capacity': 12,
        'currentCount': 7,
      },
    ];

    for (final station in stations) {
      await _db.collection('stations').doc(station['id'] as String).set({
        'name': station['name'],
        'capacity': station['capacity'],
        'currentCount': station['currentCount'],
      });
    }

    print('✅ 대여소 초기화 완료');
  }
}
