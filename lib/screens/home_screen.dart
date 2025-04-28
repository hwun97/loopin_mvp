import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_sign_in_service.dart';
import '../services/firestore_service.dart'; // FirestoreService import 추가

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
            Text(
              user?.isAnonymous == true
                  ? '익명 사용자로 로그인 중'
                  : '환영합니다, ${user?.displayName ?? '사용자'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await FirestoreService.rentUmbrellaForUser();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('우산 대여 완료')));
              },
              child: const Text('우산 대여하기'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await FirestoreService.returnUmbrellaForUser();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('우산 반납 완료')));
              },
              child: const Text('우산 반납하기'),
            ),
          ],
        ),
      ),
    );
  }
}
