package be.rmdy.one_trust_headless_sdk.ot

class SDKService {

    var initialized = false

    fun initialize() {
        if (!initialized) {

        }
        initialized = true
    }

    fun getOTSDKData(): String {
        return "test data";
    }

}