import Flutter
import UIKit
import OTPublishersHeadlessSDK

public class SwiftOneTrustHeadlessSdkPlugin: NSObject {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "one_trust_headless_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftOneTrustHeadlessSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
}

extension SwiftOneTrustHeadlessSdkPlugin: FlutterPlugin {x
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
                let sdkParams = OTSdkParams(countryCode: "US", regionCode: "CA")
                sdkParams.setSDKVersion("6.5.0")
                OTPublishersHeadlessSDK.shared.initOTSDKData(storageLocation: "otcc-demo.otprivacy.com", domainIdentifier: "3598fb78-0000-1111-2222-83ee558d6e87", languageCode: "en", params: sdkParams) { (status, error) in
                    print("OTT Data fetch result \(status) and error \(String(describing: error ?? nil))")
                }
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
