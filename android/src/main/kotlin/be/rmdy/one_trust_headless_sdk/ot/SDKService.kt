package be.rmdy.one_trust_headless_sdk.ot

import android.content.Context
import android.util.Log
import com.onetrust.otpublishers.headless.Public.DataModel.OTSdkParams
import com.onetrust.otpublishers.headless.Public.OTCallback;
import com.onetrust.otpublishers.headless.Public.OTPublishersHeadlessSDK;
import com.onetrust.otpublishers.headless.Public.Response.OTResponse

class SDKService {

    var initialized = false
    var _sdk:OTPublishersHeadlessSDK? = null

    fun initialize(storageLocation: String, domainIdentifier: String, languageCode: String, context: Context, onResult: (Boolean) -> Unit) {
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

    fun querySDKConsentStatus(sDKId: String): Int {
        return _sdk?.getConsentStatusForSDKId(sDKId) ?: -1
    }

    fun querySDKConsentStatusForCategory(customGroupId: String): Int {
        return _sdk?.getConsentStatusForGroupId(customGroupId) ?: -1
    }

    fun updateSdkGroupConsent(customGroupId: String, consentGiven: Boolean){
        _sdk?.updatePurposeConsent(customGroupId, consentGiven)
        _sdk?.saveConsentValueForCategory();
        _sdk?.resetUpdatedConsent();
    }

    fun confirmConsentChanges(){
        _sdk?.saveConsentValueForCategory();
    }

    fun resetConsentChanges(){
        _sdk?.resetUpdatedConsent();
    }
}