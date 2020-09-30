
import 'dart:async';

import 'package:flutter/services.dart';

class OneTrustHeadlessSdk {
  static const MethodChannel _channel =
      const MethodChannel('one_trust_headless_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
