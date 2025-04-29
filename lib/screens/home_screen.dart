import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/google_sign_in_service.dart';
import 'qr_scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

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
            // 로그인 상태 표시
            Text(
              user?.isAnonymous == true
                  ? '익명 사용자로 로그인 중'
                  : '환영합니다, ${user?.displayName ?? '사용자'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),

            // 우산 대여 버튼
            ElevatedButton(
              onPressed: () async {
                if (user == null) return;

                final umbrellaId = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScanScreen()),
                );

                if (umbrellaId == null) return;

                try {
                  await FirestoreService.rentUmbrella(umbrellaId, user.uid);
                  await FirestoreService.rentUmbrellaForUser();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('[$umbrellaId] 우산 대여 완료!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('대여 중 오류 발생: $e')));
                }
              },
              child: const Text('우산 대여하기 (QR 스캔)'),
            ),
            const SizedBox(height: 16),

            // 우산 반납 버튼
            ElevatedButton(
              onPressed: () async {
                if (user == null) return;

                final umbrellaId = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const QRScanScreen()),
                );

                if (umbrellaId == null) return;

                try {
                  await FirestoreService.returnUmbrella(umbrellaId);
                  await FirestoreService.returnUmbrellaForUser();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('[$umbrellaId] 우산 반납 완료!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('반납 중 오류 발생: $e')));
                }
              },
              child: const Text('우산 반납하기 (QR 스캔)'),
            ),
          ],
        ),
      ),
    );
  }
}
