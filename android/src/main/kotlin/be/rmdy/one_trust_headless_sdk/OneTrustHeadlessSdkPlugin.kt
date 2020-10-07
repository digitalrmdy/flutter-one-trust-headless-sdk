package be.rmdy.one_trust_headless_sdk

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull;
import be.rmdy.one_trust_headless_sdk.ot.SDKService

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** OneTrustHeadlessSdkPlugin */
public class OneTrustHeadlessSdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  private val sdkService = SDKService()

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "one_trust_headless_sdk")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method != "init" && !sdkService.initialized) {
      result.error("1", "Please call init first", "")
    } else {
        executeChannels(call, result)
    }
  }

    private fun executeChannels(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> {
                val storageLocation:String = call.argument<String>("storageLocation")!!
                val domainIdentifier:String = call.argument<String>("domainIdentifier")!!
                val languageCode:String = call.argument<String>("languageCode")!!
                val countryCode:String = call.argument<String>("countryCode")!!
                val regionCode:String? = call.argument<String>("regionCode")
                sdkService.initialize(storageLocation, domainIdentifier, languageCode, countryCode, regionCode, context, object: (Boolean) -> Unit {
                    override fun invoke(success: Boolean) {
                        if (success) {
                            result.success(null)
                        }  else {
                            result.error("", "Could not init sdk", null)
                        }
                    }
                } )
            }
            "shouldShowBanner" -> {
                return result.success(sdkService.shouldShowBanner())
            }
            "getOTSDKData" -> {
                return result.success(sdkService.getOTSDKData())
            }
            "acceptAll" -> {
                sdkService.acceptAll()
                return result.success(null)
            }
            "queryConsentStatusForSdk" -> {
                val sdkId:String = call.argument<String>("sdkId")!!
                return result.success(sdkService.querySDKConsentStatus(sdkId))
            }
            "updateSdkGroupConsent" -> {
                val customGroupId:String = call.argument<String>("customGroupId")!!
                val consentGiven:Boolean = call.argument<Boolean>("consentGiven")!!
                sdkService.updateSdkGroupConsent(customGroupId, consentGiven)
                result.success(null)
            }
            "queryConsentStatusForCategory" -> {
                val customGroupId:String = call.argument<String>("customGroupId")!!
                return result.success(sdkService.querySDKConsentStatusForCategory(customGroupId))
            }
            "confirmConsentChanges" -> {
                sdkService.confirmConsentChanges()
                return result.success(null)
            }
            "resetConsentChanges" -> {
                sdkService.resetConsentChanges()
                return result.success(null)
            }
            "registerSdkListener" -> {
                val sdkId:String = call.argument<String>("sdkId")!!
                sdkService.registerSdkListener(sdkId, this::sdkConsentStatusUpdated)
                return result.success(null)
            }
            "clearSdkListeners" -> {
                sdkService.clearSdkListeners()
                return result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun sdkConsentStatusUpdated(sdkId: String, consentStatus: Int) {
        channel.invokeMethod("sdkConsentStatusUpdated", mapOf("sdkId" to sdkId, "consentStatus" to consentStatus) )
    }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
      sdkService.clearSdkListeners()
    channel.setMethodCallHandler(null)
  }
}
