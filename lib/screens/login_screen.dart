import 'package:flutter/material.dart';
import '../services/google_sign_in_service.dart';
import '../services/auth_service.dart'; // 익명 로그인용

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoopIn 로그인')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '환영합니다!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // ✅ Google 로그인 버튼
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Google로 로그인"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  try {
                    final user = await GoogleSignInService.signInWithGoogle();
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text("로그인 취소됨")));
                    }
                  } catch (e) {
                    print('Google 로그인 오류: $e');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("로그인 실패")));
                  }
                },
              ),

              const SizedBox(height: 20),

              // ✅ 익명 로그인 버튼
              ElevatedButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Text("로그인 없이 시작하기"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  try {
                    final user = await AuthService.signInAnonymously();
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("익명 로그인 실패")),
                      );
                    }
                  } catch (e) {
                    print('익명 로그인 오류: $e');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("로그인 실패")));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
