package be.rmdy.one_trust_headless_sdk.ot

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.onetrust.otpublishers.headless.Public.DataModel.OTSdkParams
import com.onetrust.otpublishers.headless.Public.OTCallback;
import com.onetrust.otpublishers.headless.Public.OTPublishersHeadlessSDK;
import com.onetrust.otpublishers.headless.Public.Response.OTResponse

class SDKService {

    var initialized = false
    var _sdk:OTPublishersHeadlessSDK? = null
    var context: Context? = null

    var receivers : MutableMap<String, BroadcastReceiver> = mutableMapOf()

    fun initialize(storageLocation: String, domainIdentifier: String, languageCode: String, context: Context, onResult: (Boolean) -> Unit) {
            this.context = context;
            _sdk = OTPublishersHeadlessSDK(context)
            val sdkParams = OTSdkParams.SdkParamsBuilder.newInstance()
                    .setAPIVersion("6.6.1")
                    .shouldCreateProfile(true)
                    .build()
            _sdk!!.initOTSDKData(storageLocation, domainIdentifier, languageCode,
                    sdkParams,
                    object : OTCallback {
                        override fun onSuccess(response: OTResponse) {
                            initialized = true
                            onResult(true)
                        }

                        override fun onFailure(response: OTResponse) {
                            initialized = false
                            onResult(false)
                        }
                    })
    }

    fun getOTSDKData(): String {
        return _sdk?.otsdkData ?: ""
    }

    fun shouldShowBanner(): Boolean {
        return _sdk?.shouldShowBanner() ?: false
    }

    fun acceptAll() {
        _sdk?.acceptAll()
    }

    fun querySDKConsentStatus(sdkId: String): Int {
        return _sdk?.getConsentStatusForSDKId(sdkId) ?: -1
    }

    fun querySDKConsentStatusForCategory(customGroupId: String): Int {
        return _sdk?.getConsentStatusForGroupId(customGroupId) ?: -1
    }

    fun updateSdkGroupConsent(customGroupId: String, consentGiven: Boolean){
        _sdk?.updatePurposeConsent(customGroupId, consentGiven)
    }

    fun confirmConsentChanges(){
        _sdk?.saveConsentValueForCategory();
    }

    fun resetConsentChanges(){
        _sdk?.resetUpdatedConsent();
    }

    fun registerSdkListener(sdkId: String, onSdkConsentStatusUpdated: (String, Int) -> Unit) {
        var broadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                onSdkConsentStatusUpdated(intent.action!!, intent.getIntExtra("OTT_EVENT_STATUS", -1))
            }
        }
        val filter = IntentFilter(sdkId)
        context?.registerReceiver(broadcastReceiver, filter)
        receivers[sdkId] = broadcastReceiver
        Log.i("OTHSP", "Registered BroadcastReceiver for $sdkId ")
    }

    fun clearSdkListeners() {
        Log.i("OTHSP", "Unregistering ${receivers.size} BroadcastReceivers ")
        for (receiver in receivers.values) {
            context?.unregisterReceiver(receiver)
        }
    }
}