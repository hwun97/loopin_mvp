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
  final User? user = FirebaseAuth.instance.currentUser;
  String? rentalStatus;
  bool isLoading = true; // 데이터 로딩 중 표시용

  @override
  void initState() {
    super.initState();
    _fetchRentalStatus();
  }

  Future<void> _fetchRentalStatus() async {
    if (user == null) return;
    final status = await FirestoreService.getRentalStatus();
    setState(() {
      rentalStatus = status;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('로그인 오류')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
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
              : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user!.isAnonymous
                          ? '익명 사용자로 로그인 중'
                          : '환영합니다, ${user!.displayName ?? '사용자'}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 32),

                    // 버튼 표시 (대여 중이면 반납 버튼만 / 아니면 대여 버튼만)
                    if (rentalStatus != 'rented')
                      ElevatedButton(
                        onPressed: () async {
                          final umbrellaId = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QRScanScreen(),
                            ),
                          );
                          if (umbrellaId == null) return;

                          await FirestoreService.rentUmbrella(
                            umbrellaId,
                            user!.uid,
                          );
                          await FirestoreService.rentUmbrellaForUser();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('[$umbrellaId] 우산 대여 완료!')),
                          );

                          // 상태 갱신
                          _fetchRentalStatus();
                        },
                        child: const Text('우산 대여하기 (QR 스캔)'),
                      ),

                    if (rentalStatus == 'rented')
                      ElevatedButton(
                        onPressed: () async {
                          final umbrellaId = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QRScanScreen(),
                            ),
                          );
                          if (umbrellaId == null) return;

                          await FirestoreService.returnUmbrella(umbrellaId);
                          await FirestoreService.returnUmbrellaForUser();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('[$umbrellaId] 우산 반납 완료!')),
                          );

                          // 상태 갱신
                          _fetchRentalStatus();
                        },
                        child: const Text('우산 반납하기 (QR 스캔)'),
                      ),
                  ],
                ),
              ),
    );
  }
}
