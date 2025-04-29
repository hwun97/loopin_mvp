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
  bool isLoading = true;

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

  Future<void> _handleRentalAction(String action) async {
    final umbrellaId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanScreen()),
    );

    if (umbrellaId == null) return;

    try {
      if (action == 'rent') {
        await FirestoreService.rentUmbrella(umbrellaId, user!.uid);
        await FirestoreService.rentUmbrellaForUser();
        await FirestoreService.addRentalLog(
          userId: user!.uid,
          umbrellaId: umbrellaId,
          action: 'rent',
        );
      } else if (action == 'return') {
        await FirestoreService.returnUmbrella(umbrellaId);
        await FirestoreService.returnUmbrellaForUser();
        await FirestoreService.addRentalLog(
          userId: user!.uid,
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
      }

      _fetchRentalStatus(); // 성공하면 상태 갱신
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
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      if (rentalStatus != 'rented')
                        ElevatedButton(
                          onPressed: () => _handleRentalAction('rent'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('우산 대여하기 (QR 스캔)'),
                        ),

                      if (rentalStatus == 'rented')
                        ElevatedButton(
                          onPressed: () => _handleRentalAction('return'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text('우산 반납하기 (QR 스캔)'),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
