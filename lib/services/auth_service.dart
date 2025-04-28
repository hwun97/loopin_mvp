import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  // 익명 로그인
  static Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('익명 로그인 실패: $e');
      return null;
    }
  }

  // 로그아웃
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
