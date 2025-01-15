import Flutter
import UIKit
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Firebaseの初期化
      FirebaseApp.configure()
      
      // Flutterのプラグイン登録
      GeneratedPluginRegistrant.register(with:self)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
