import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loopin_mvp/screens/qr_scan_screen.dart';
import '../services/google_sign_in_service.dart';
import '../services/firestore/rental_service.dart';
import '../services/firestore/station_service.dart';
import '../services/firestore/log_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String? rentalStatus;
  String? stationId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRentalStatus();
  }

  // 현재 사용자의 대여 상태 확인
  Future<void> _fetchRentalStatus() async {
    if (user == null) return;

    final status = await RentalService.getRentalStatus();
    String? fetchedStationId;

    if (status == 'rented') {
      final rentalDoc = await RentalService.getRentalDoc();
      fetchedStationId = rentalDoc?.data()?['stationId'];
    }

    setState(() {
      rentalStatus = status;
      stationId = fetchedStationId;
      isLoading = false;
    });
  }

  // 대여 또는 반납 처리
  Future<void> _handleRentalAction(String action) async {
    final scannedStationId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanScreen()),
    );

    if (scannedStationId == null) return;

    try {
      if (action == 'rent') {
        await StationService.rentFromStation(scannedStationId);
        await RentalService.rentForUser(scannedStationId);
        await LogService.addRentalLog(
          userId: user!.uid,
          stationId: scannedStationId,
          action: 'rent',
        );
      } else if (action == 'return') {
        await StationService.returnToStation(scannedStationId);
        await RentalService.returnForUser();
        await LogService.addRentalLog(
          userId: user!.uid,
          stationId: scannedStationId,
          action: 'return',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '[$scannedStationId] 우산 ${action == 'rent' ? '대여' : '반납'} 완료!',
            ),
          ),
        );
        _fetchRentalStatus(); // 상태 갱신
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('로그인 오류')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('LoopIn 홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await GoogleSignInService.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user!.isAnonymous
                            ? '익명 사용자로 로그인 중'
                            : '환영합니다, ${user!.displayName ?? '사용자'}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        rentalStatus == 'rented'
                            ? '✅ 현재 우산 대여 중'
                            : '🅾️ 대여 중인 우산 없음',
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (rentalStatus == 'rented' && stationId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '대여소 ID: $stationId',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed:
                            () => _handleRentalAction(
                              rentalStatus == 'rented' ? 'return' : 'rent',
                            ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: Text(
                          rentalStatus == 'rented'
                              ? '우산 반납하기 (QR 스캔)'
                              : '우산 대여하기 (QR 스캔)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
