import 'dart:async';

import 'package:flutter/services.dart';
import 'package:one_trust_headless_sdk/model/otsdkdata.dart';

class OneTrustHeadlessSdk {
  static const MethodChannel _channel =
      const MethodChannel('one_trust_headless_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<OTSDKData> get oTSDKData async {
    final String data = await _channel.invokeMethod('getOTSDKData');
    return OTSDKData(data);
  }
}
