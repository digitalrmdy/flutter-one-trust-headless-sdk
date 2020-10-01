package be.rmdy.one_trust_headless_sdk.ot

import android.content.Context
import com.onetrust.otpublishers.headless.Public.DataModel.OTSdkParams
import com.onetrust.otpublishers.headless.Public.OTCallback;
import com.onetrust.otpublishers.headless.Public.OTPublishersHeadlessSDK;
import com.onetrust.otpublishers.headless.Public.Response.OTResponse

class SDKService {

    var initialized = false
    var _sdk:OTPublishersHeadlessSDK? = null

    fun initialize(context: Context, onResult: (Boolean) -> Unit) {
        if (!initialized) {
            _sdk = OTPublishersHeadlessSDK(context)
            val sdkParams = OTSdkParams.SdkParamsBuilder.newInstance()
                    .setAPIVersion("6.6.1")
                    .shouldCreateProfile(true)
                    .build()
            _sdk!!.initOTSDKData("cdn.cookielaw.org", "f1383ce9-d3ad-4e0d-98bf-6e736846266b-test", "en",
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
    }

    fun getOTSDKData(): String {
        val sdk = _sdk
        return if (sdk != null) {
            sdk.otsdkData
        } else {
            "";
        }
    }
}