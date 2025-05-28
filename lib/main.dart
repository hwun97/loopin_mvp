import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/email_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/station_map_screen.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '5cb90e12073dc07d66926e91f7a629ad');

  // ✅ Firebase 초기화
  await _initializeFirebase();

  // ✅ Naver Map 초기화 (인스턴스 방식)
  final naverMap = FlutterNaverMap();
  await naverMap.init(clientId: 'r83wucnh0o');

  // ✅ 네트워크 테스트
  await testNetwork();

  runApp(const LoopInApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase 초기화 완료");
  } catch (e) {
    print('❌ Firebase 초기화 실패: $e');
  }
}

Future<void> testNetwork() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    print('✅ Network OK: ${response.statusCode}');
  } catch (e) {
    print('❌ Network Error: $e');
  }
}

class LoopInApp extends StatelessWidget {
  const LoopInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '드리움',
      debugShowCheckedModeBanner: false,
      theme: loopinTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/scan': (context) => const QRScanScreen(),
        '/email': (context) => const EmailLoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/map': (context) => const StationMapScreen(),
      },
    );
  }
}
