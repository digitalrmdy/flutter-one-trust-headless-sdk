package be.rmdy.one_trust_headless_sdk.ot

import android.content.Context
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
        val sdk = _sdk
        return if (sdk != null) {
            sdk.otsdkData
        } else {
            "";
        }
    }

    fun shouldShowBanner(): Boolean {
        val sdk = _sdk
        return sdk?.shouldShowBanner() ?: false
    }
}