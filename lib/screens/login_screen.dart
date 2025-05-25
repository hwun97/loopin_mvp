import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/google_sign_in_service.dart';
import '../services/kakao_sign_in_service.dart';
import '../widgets/social_login_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SocialLoginButton(
                text: "Google로 시작하기",
                iconPath: 'assets/google_icon.png',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onPressed: () async {
                  final user = await GoogleSignInService.signInWithGoogle();
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ).animate().slideY(begin: 1, end: 0, duration: 500.ms).fadeIn(),
              const SizedBox(height: 16),
              SocialLoginButton(
                text: "Kakao로 시작하기",
                iconPath: 'assets/kakao_icon.png',
                backgroundColor: const Color(0xFFFEE500),
                textColor: Colors.black,
                onPressed: () async {
                  final user = await KakaoSignInService.signInWithKakao();
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ).animate().slideY(begin: 1, end: 0, duration: 600.ms).fadeIn(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton(
                          onPressed:
                              () => Navigator.pushNamed(context, '/email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF21c3c5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "이메일로 로그인하기",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .animate()
                        .slideY(begin: 1, end: 0, duration: 700.ms)
                        .fadeIn(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
