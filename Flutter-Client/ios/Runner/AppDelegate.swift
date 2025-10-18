import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let nativeChannel = FlutterMethodChannel(name: "com.grabtube.app/native",
                                              binaryMessenger: controller.binaryMessenger)

    nativeChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard call.method == "getDeviceInfo" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.getDeviceInfo(result: result)
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getDeviceInfo(result: FlutterResult) {
    let deviceInfo: [String: String] = [
      "name": UIDevice.current.name,
      "model": UIDevice.current.model,
      "systemName": UIDevice.current.systemName,
      "systemVersion": UIDevice.current.systemVersion
    ]
    result(deviceInfo)
  }
}
