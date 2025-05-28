import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loopin_mvp/services/firestore/station_service.dart';

class StationMapScreen extends StatefulWidget {
  const StationMapScreen({Key? key}) : super(key: key);

  @override
  State<StationMapScreen> createState() => _StationMapScreenState();
}

class _StationMapScreenState extends State<StationMapScreen> {
  late NaverMapController _mapController;
  final List<NMarker> _markers = [];

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
    _loadStations();
  }

  /// Geolocator로 위치 권한 요청
  Future<void> _checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('위치 권한이 필요합니다')));
      }
    }
  }

  /// 현재 위치로 카메라 이동
  Future<void> _moveToCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _mapController.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      );
    } catch (e) {
      debugPrint('❌ 현재 위치 가져오기 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('현재 위치를 가져올 수 없습니다')));
      }
    }
  }

  /// Firebase에서 대여소 데이터를 불러와 마커 생성
  Future<void> _loadStations() async {
    final stations = await StationService.getAllStations();

    for (var station in stations) {
      final location = station['location'];
      if (location == null ||
          location['lat'] == null ||
          location['lng'] == null) {
        debugPrint('⚠️ 위치 정보 누락된 대여소 스킵: ${station['id']}');
        continue;
      }

      final lat = double.tryParse(location['lat'].toString()) ?? 0;
      final lng = double.tryParse(location['lng'].toString()) ?? 0;

      if (lat == 0 || lng == 0) {
        debugPrint('⚠️ 좌표값 파싱 실패: ${station['id']}');
        continue;
      }

      final name = station['name'] ?? '이름 없음';
      final id = station['id'];
      final currentCount = station['currentCount'] ?? 0;
      final capacity = station['capacity'] ?? 0;

      final marker = NMarker(
        id: id,
        position: NLatLng(lat, lng),
        caption: NOverlayCaption(text: name),
      );

      marker.setOnTapListener((_) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(name),
                content: Text('보유 우산: $currentCount / $capacity'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ],
              ),
        );
      });

      _markers.add(marker);
    }

    if (mounted) {
      _mapController.addOverlayAll(_markers.toSet());
      debugPrint('✅ 마커 전체 지도에 추가 완료 (${_markers.length}개)');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공유 우산 대여소 지도')),
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(37.540, 127.070),
                zoom: 14,
              ),
              locationButtonEnable: false,
            ),
            onMapReady: (controller) async {
              _mapController = controller;
              _mapController.addOverlayAll(_markers.toSet());
              await _moveToCurrentLocation();
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _moveToCurrentLocation,
              backgroundColor: const Color(0xFF21c3c5),
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
