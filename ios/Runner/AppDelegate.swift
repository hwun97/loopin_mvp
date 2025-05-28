import Flutter
import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import NMapsMap

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ✅ 카카오 SDK 초기화
    KakaoSDK.initSDK(appKey: "5cb90e12073dc07d66926e91f7a629ad")

    // ✅ 네이버 지도 클라이언트 ID 설정
    NMFAuthManager.shared().clientId = "r83wucnh0o"

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL,
                            options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if (AuthApi.isKakaoTalkLoginUrl(url)) {
      return AuthController.handleOpenUrl(url: url)
    }
    return super.application(app, open: url, options: options)
  }
}
