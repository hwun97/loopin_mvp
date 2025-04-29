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
  String? rentalStatus; // 'rented' or 'returned' or null
  bool isLoading = true; // 상태를 불러오는 동안 true

  @override
  void initState() {
    super.initState();
    _loadRentalStatus();
  }

  Future<void> _loadRentalStatus() async {
    if (user == null) return;
    final status = await FirestoreService.getRentalStatus();
    setState(() {
      rentalStatus = status;
      isLoading = false;
    });
  }

  Future<void> _handleAction() async {
    if (user == null) return;

    final umbrellaId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QRScanScreen()),
    );
    if (umbrellaId == null) return;

    setState(() => isLoading = true);

    try {
      if (rentalStatus == 'rented') {
        await FirestoreService.returnUmbrella(umbrellaId);
        await FirestoreService.returnUmbrellaForUser();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('[$umbrellaId] 우산 반납 완료!')));
      } else {
        await FirestoreService.rentUmbrella(umbrellaId, user!.uid);
        await FirestoreService.rentUmbrellaForUser();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('[$umbrellaId] 우산 대여 완료!')));
      }
      await _loadRentalStatus(); // 완료 후 상태 갱신
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
      setState(() => isLoading = false); // 실패하면 다시 false
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('로그인 정보를 가져올 수 없습니다.')));
    }

    final isRented = rentalStatus == 'rented';
    final actionText =
        isLoading
            ? '로딩 중...'
            : isRented
            ? '우산 반납하기 (QR 스캔)'
            : '우산 대여하기 (QR 스캔)';

    final isButtonEnabled = !isLoading; // 로딩 중에는 비활성화

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
      body: Center(
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

            ElevatedButton(
              onPressed: isButtonEnabled ? _handleAction : null, // 비활성화
              child: Text(actionText),
            ),
          ],
        ),
      ),
    );
  }
}
