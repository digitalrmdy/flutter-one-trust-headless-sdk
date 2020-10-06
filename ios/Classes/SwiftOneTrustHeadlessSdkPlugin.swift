import Flutter
import UIKit

public class SwiftOneTrustHeadlessSdkPlugin: NSObject {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "one_trust_headless_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftOneTrustHeadlessSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}

extension SwiftOneTrustHeadlessSdkPlugin: FlutterPlugin {
    private enum MethodChannel: String {
        case initOT = "init"
        case shouldShowBanner
        case getOTSDKData
        case acceptAll
        case querySDKConsentStatus
        case updateSdkGroupConsent
        case querySDKConsentStatusForCategory
        case confirmConsentChanges
        case resetConsentChanges
        case registerSdkListener
        case clearSdkListeners
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let method = MethodChannel(rawValue: call.method) else {
            result(FlutterMethodNotImplemented)
            return
        }
        switch method {
            case .initOT:
                break;
            case .shouldShowBanner:
                break;
            case .getOTSDKData:
                break;
            case .acceptAll:
                break;
            case .querySDKConsentStatus:
                break;
            case .updateSdkGroupConsent:
                break;
            case .querySDKConsentStatusForCategory:
                break;
            case .confirmConsentChanges:
                break;
            case .resetConsentChanges:
                break;
            case .registerSdkListener:
                break;
            case .clearSdkListeners:
                break;
        }
    }
}