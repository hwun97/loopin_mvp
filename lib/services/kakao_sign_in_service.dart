import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class KakaoSignInService {
  static Future<firebase_auth.User?> signInWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      bool isInstalled = await kakao.isKakaoTalkInstalled();

      kakao.OAuthToken token;
      if (isInstalled) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 사용자 정보 요청 (여기서 id 등 사용 가능)
      final kakaoUser = await kakao.UserApi.instance.me();
      final kakaoUid = kakaoUser.id.toString();
      print('카카오 로그인 성공, UID: $kakaoUid');

      // 🔧 Firebase 커스텀 토큰 연동 전에는 익명 로그인으로 대체
      final result =
          await firebase_auth.FirebaseAuth.instance.signInAnonymously();

      return result.user;
    } catch (e) {
      print('카카오 로그인 오류: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await kakao.UserApi.instance.logout();
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      print('카카오 로그아웃 오류: $e');
    }
  }
}
