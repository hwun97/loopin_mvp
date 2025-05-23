import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qr_scan_screen.dart';
// import 'services/firestore/firestore_init.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩을 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 예외 발생 시 앱이 크래시 나는 걸 막기 위한 설정
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ [주의] 아래 코드는 최초 실행시에만 사용! 이후 반드시 주석 처리하거나 삭제
    // await FirestoreInit.initializeStations();
  } catch (e) {
    print('Firebase 초기화 실패: $e');
  }

  runApp(const LoopInApp());
}

class LoopInApp extends StatelessWidget {
  const LoopInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoopIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/scan': (context) => const QRScanScreen(),
      },
    );
  }
}
