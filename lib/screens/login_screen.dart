import 'package:flutter/material.dart';
import '../services/google_sign_in_service.dart';
import '../services/auth_service.dart'; // ✅ 새로 추가

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoopIn 로그인')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Google로 로그인"),
              onPressed: () async {
                final user = await GoogleSignInService.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("로그인 실패")));
                }
              },
            ),
            const SizedBox(height: 20), // 구글 로그인 버튼과 간격
            ElevatedButton.icon(
              icon: const Icon(Icons.person_outline),
              label: const Text("로그인 없이 시작하기"),
              onPressed: () async {
                final user = await AuthService.signInAnonymously(); // ✅
                if (user != null) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("익명 로그인 실패")));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
