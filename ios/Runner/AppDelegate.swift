import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    let objreciver:GeofencingEventsReceiver = GeofencingEventsReceiver()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    objreciver.startReceivingEvent()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
