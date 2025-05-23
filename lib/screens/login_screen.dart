import 'package:flutter/material.dart';
import '../services/google_sign_in_service.dart';
import '../services/kakao_sign_in_service.dart';
// import '../services/auth_service.dart';
import '../widgets/social_login_button.dart'; // 위 위젯 임포트

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 이미지처럼 배경 검정색
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
              ),
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
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  // final user = await AuthService.signInAnonymously();
                  // if (user != null) {
                  //   Navigator.pushReplacementNamed(context, '/home');
                  // }
                  Navigator.pushNamed(context, '/email');
                },
                child: const Text(
                  "이메일로 로그인하기",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
