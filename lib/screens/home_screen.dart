import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loopin_mvp/screens/qr_scan_screen.dart';
import '../services/firestore/rental_service.dart';
import '../services/firestore/station_service.dart';
import '../services/firestore/log_service.dart';
import '../widgets/loading_dialog.dart';

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
  int passCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchRentalStatus();
  }

  Future<void> _fetchRentalStatus() async {
    if (user == null) return;

    final status = await RentalService.getRentalStatus();
    String? fetchedStationId;
    final count = await RentalService.getRemainingPassCount(user!.uid);

    if (status == 'rented') {
      final rentalDoc = await RentalService.getRentalDoc();
      fetchedStationId = rentalDoc?.data()?['stationId'];
    }

    setState(() {
      rentalStatus = status;
      stationId = fetchedStationId;
      isLoading = false;
      passCount = count;
    });
  }

  Future<void> _handleRentalAction(String action) async {
    final scannedStationId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanScreen()),
    );

    debugPrint('[handleRentalAction] 스캔 결과: $scannedStationId');

    if (scannedStationId == null) {
      debugPrint('[handleRentalAction] 스캔 실패, 리턴');
      return;
    }

    // ✅ 작은 딜레이를 주자. Navigator.pop 직후에 showDialog 실행되면 UI thread 블로킹 발생 가능
    await Future.delayed(const Duration(milliseconds: 100));

    debugPrint('[handleRentalAction] showLoadingDialog 호출 전');

    final dialogFuture = showLoadingDialog(
      context,
      message: action == 'rent' ? '대여 처리 중...' : '반납 처리 중...',
    );

    debugPrint('[handleRentalAction] showLoadingDialog 호출 완료');

    // ✅ 이후 로직은 Future.microtask 로 밀어넣어 async queue 확보
    Future.microtask(() async {
      try {
        if (action == 'rent') {
          debugPrint('step 1');
          final hasPass = await RentalService.hasValidPass(user!.uid);
          debugPrint('step 2');
          if (!hasPass) {
            debugPrint('step 2.1: no pass');
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('이용권이 없습니다.')));
            }
            return;
          }

          debugPrint('step 3');
          await StationService.rentFromStation(scannedStationId);
          debugPrint('step 4');
          await RentalService.rentForUser(scannedStationId);
          debugPrint('step 5');
          await LogService.addRentalLog(
            userId: user!.uid,
            stationId: scannedStationId,
            action: 'rent',
          );
          debugPrint('step 6');
        } else if (action == 'return') {
          debugPrint('step 7');
          await StationService.returnToStation(scannedStationId);
          debugPrint('step 8');
          await RentalService.returnForUser();
          debugPrint('step 9');
          await LogService.addRentalLog(
            userId: user!.uid,
            stationId: scannedStationId,
            action: 'return',
          );
          debugPrint('step 10');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('[$scannedStationId] 우산 $action 완료!')),
          );
          _fetchRentalStatus();
        }
      } catch (e) {
        debugPrint('[handleRentalAction] 예외 발생: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
        }
      } finally {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // 로딩 다이얼로그 닫기
          debugPrint('[handleRentalAction] 로딩 다이얼로그 닫음');
        }
      }
    });

    await dialogFuture;
  }

  Future<void> _handleIssueTestPass() async {
    try {
      await RentalService.issueTestPass();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('테스트용 이용권이 발급되었습니다.')));
      _fetchRentalStatus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이용권 발급 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('로그인 오류')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('드리움 홈')),
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
                          color: Color(0xFF21c3c5),
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
                      const SizedBox(height: 8),
                      Text(
                        '남은 이용권: $passCount개',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed:
                            () => _handleRentalAction(
                              rentalStatus == 'rented' ? 'return' : 'rent',
                            ),
                        child: Text(
                          rentalStatus == 'rented'
                              ? '우산 반납하기 (QR 스캔)'
                              : '우산 대여하기 (QR 스캔)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _handleIssueTestPass,
                        child: const Text('테스트용 이용권 받기'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
