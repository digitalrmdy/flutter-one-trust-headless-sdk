import Flutter
import UIKit

public class SwiftOneTrustHeadlessSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "one_trust_headless_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftOneTrustHeadlessSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
