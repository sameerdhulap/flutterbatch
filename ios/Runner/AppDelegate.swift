import Flutter
import UIKit
import BrazeKit
import braze_plugin

@main
@objc class AppDelegate: FlutterAppDelegate {
    let objreciver:GeofencingEventsReceiver = GeofencingEventsReceiver()
    static var braze: Braze? = nil
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      // Setup Braze
        let configuration = Braze.Configuration(
          apiKey: "<BRAZE_API_KEY>",
          endpoint: "<BRAZE_ENDPOINT>"
        )
        // - Enable logging or customize configuration here
        configuration.logger.level = .info
        let braze = BrazePlugin.initBraze(configuration)
        AppDelegate.braze = braze

    GeneratedPluginRegistrant.register(with: self)
    objreciver.startReceivingEvent()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
