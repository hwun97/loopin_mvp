import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 익명 로그인 수행
  static Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('익명 로그인 실패: $e');
      return null;
    }
  }

  /// 로그아웃 (Firebase 인증 상태 초기화)
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
