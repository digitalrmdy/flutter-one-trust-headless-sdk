import Flutter
import UIKit
import OTPublishersHeadlessSDK

public class SwiftOneTrustHeadlessSdkPlugin: NSObject {
    var registeredListeners = [String]()
    static var channel: FlutterMethodChannel? = nil
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "one_trust_headless_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftOneTrustHeadlessSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel!)
  }
}

extension SwiftOneTrustHeadlessSdkPlugin: FlutterPlugin {
    
    private enum MethodChannel: String {
        case initOT = "init"
        case shouldShowBanner
        case getOTSDKData
        case acceptAll
        case queryConsentStatusForSdk
        case updateSdkGroupConsent
        case queryConsentStatusForCategory
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
                let args = call.arguments as! [String: Any]
                let storageLocation = args["storageLocation"] as! String
                let domainIdentifier = args["domainIdentifier"] as! String
                let languageCode = args["languageCode"] as! String
                let countryCode = args["countryCode"] as! String
                let regionCode = args["regionCode"] as! String?
                let sdkParams = OTSdkParams(countryCode: countryCode, regionCode: regionCode)
                sdkParams.setSDKVersion("6.7.0")
                sdkParams.setShouldCreateProfile("true")
                OTPublishersHeadlessSDK.shared.initOTSDKData(storageLocation: storageLocation, domainIdentifier: domainIdentifier, languageCode: languageCode, params: sdkParams) { (status, error) in
                    if (!status) {
                        result(FlutterError(code: "", message: error.debugDescription, details: ""))
                    } else {
                        result(nil)
                    }
                }
                break;
            case .shouldShowBanner:
                result(OTPublishersHeadlessSDK.shared.shouldShowBanner())
                break;
            case .getOTSDKData:
                result(OTPublishersHeadlessSDK.shared.getOTSDKData() ?? "")
                break;
            case .acceptAll:
                OTPublishersHeadlessSDK.shared.acceptAll()
                result(nil)
                break;
            case .queryConsentStatusForSdk:
                let args = call.arguments as! [String: Any]
                let sdkId = args["sdkId"] as! String
                result(OTPublishersHeadlessSDK.shared.getConsentStatus(forSDKId: sdkId))
                break;
            case .updateSdkGroupConsent:
                let args = call.arguments as! [String: Any]
                let customGroupId = args["customGroupId"] as! String
                let consentGiven = args["consentGiven"] as! Bool
                OTPublishersHeadlessSDK.shared.updatePurposeConsent(forGroup: customGroupId, consentValue: consentGiven)
                result(nil)
                break;
            case .queryConsentStatusForCategory:
                let args = call.arguments as! [String: Any]
                let customGroupId = args["customGroupId"] as! String
                result(OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: customGroupId))
                break;
            case .confirmConsentChanges:
                OTPublishersHeadlessSDK.shared.saveConsentValue()
                result(nil)
                break;
            case .resetConsentChanges:
                OTPublishersHeadlessSDK.shared.resetUpdatedConsent()
                result(nil)
                break;
            case .registerSdkListener:
                let args = call.arguments as! [String: Any]
                let sdkId = args["sdkId"] as! String
                if (registeredListeners.contains(sdkId)) {
                    NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: sdkId))
                } else {
                    registeredListeners.append(sdkId);
                }
                NotificationCenter.default.addObserver(self,
                      selector: #selector(actionConsent_SDK(_:)),
                      name: NSNotification.Name(rawValue: sdkId),
                      object: nil)
                result(nil)
                break;
            case .clearSdkListeners:
                registeredListeners.forEach { sdkId  in
                    NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: sdkId))
                }
                result(nil)
                break;
        }
    }
    
    // SDK Observer Function
    @objc func actionConsent_SDK(_ notification:Notification){
        if let consentStatus = notification.object as? Int {
            var params = [String:Any]()
            params["sdkId"] = notification.name.rawValue
            params["consentStatus"] = consentStatus
            SwiftOneTrustHeadlessSdkPlugin.channel!.invokeMethod("sdkConsentStatusUpdated", arguments: params)
        }
        
    }
}
