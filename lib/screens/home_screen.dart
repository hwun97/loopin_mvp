import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loopin_mvp/screens/qr_scan_screen.dart';
import '../services/firestore_service.dart';
import '../services/google_sign_in_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? rentalStatus;
  String? rentedUmbrellaId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRentalStatus();
  }

  // 🔄 사용자 대여 상태 확인
  Future<void> _fetchRentalStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final status = await FirestoreService.getRentalStatus();
      String? umbrellaId;

      if (status == 'rented') {
        final rentalDoc = await FirestoreService.getRentalDoc(user.uid);
        umbrellaId = rentalDoc?.data()?['umbrellaId'];
      }

      setState(() {
        rentalStatus = status;
        rentedUmbrellaId = umbrellaId;
        isLoading = false;
      });
    } catch (e) {
      print('대여 상태 불러오기 실패: $e');
    }
  }

  // 🛠 대여 또는 반납 처리 로직
  Future<void> _handleRentalAction(String action) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final umbrellaId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanScreen()),
    );

    if (umbrellaId == null) return;

    try {
      if (action == 'rent') {
        await FirestoreService.rentUmbrella(umbrellaId, user.uid);
        await FirestoreService.rentUmbrellaForUser(umbrellaId);
        await FirestoreService.addRentalLog(
          userId: user.uid,
          umbrellaId: umbrellaId,
          action: 'rent',
        );
      } else {
        await FirestoreService.returnUmbrella(umbrellaId);
        await FirestoreService.returnUmbrellaForUser();
        await FirestoreService.addRentalLog(
          userId: user.uid,
          umbrellaId: umbrellaId,
          action: 'return',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '[$umbrellaId] 우산 ${action == 'rent' ? '대여' : '반납'} 완료!',
            ),
          ),
        );
        _fetchRentalStatus();
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
    final user = FirebaseAuth.instance.currentUser;

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
                      // 👋 인사말
                      Text(
                        user.isAnonymous
                            ? '익명 사용자로 로그인 중'
                            : '환영합니다, ${user.displayName ?? '사용자'}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // 📍 대여 상태 표시
                      Text(
                        rentalStatus == 'rented'
                            ? '✅ 현재 우산 대여 중'
                            : '🅾️ 대여 중인 우산 없음',
                        style: const TextStyle(fontSize: 18),
                      ),

                      // 🔖 대여된 우산 ID 표시
                      if (rentalStatus == 'rented' &&
                          rentedUmbrellaId != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '대여한 우산 ID: $rentedUmbrellaId',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // 📦 대여 or 반납 버튼
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
