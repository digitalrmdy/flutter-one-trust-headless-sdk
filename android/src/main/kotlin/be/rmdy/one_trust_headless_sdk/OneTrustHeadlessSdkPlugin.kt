package be.rmdy.one_trust_headless_sdk

import android.content.Context
import androidx.annotation.NonNull;
import be.rmdy.one_trust_headless_sdk.ot.SDKService

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

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
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "init" -> {
                val storageLocation:String = call.argument<String>("storageLocation")!!
                val domainIdentifier:String = call.argument<String>("domainIdentifier")!!
                val languageCode:String = call.argument<String>("languageCode")!!
                sdkService.initialize(storageLocation, domainIdentifier, languageCode, context, object: (Boolean) -> Unit {
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
            "querySDKConsentStatus" -> {
                val sdkId:String = call.argument<String>("sDKId")!!
                return result.success(sdkService.querySDKConsentStatus(sdkId))
            }
            else -> {
                result.notImplemented()
            }
        }
    }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
