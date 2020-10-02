import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_trust_headless_sdk/model/otsdkdata.dart';
import 'dart:developer' as developer;

/// Error codes:
/// 1: Please call init first
///

class OneTrustHeadlessSdk {
  static const MethodChannel _channel =
      const MethodChannel('one_trust_headless_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> init(
      {@required String storageLocation,
      @required String domainIdentifier,
      @required String languageCode}) async {
    try {
      await _channel.invokeMethod<bool>('init', <String, dynamic>{
        'storageLocation': storageLocation,
        'domainIdentifier': domainIdentifier,
        'languageCode': languageCode,
      });
    } on PlatformException catch (e) {
      developer.log('Error during init: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<void> acceptAll() async {
    try {
      await _channel.invokeMethod<bool>('acceptAll');
    } on PlatformException catch (e) {
      developer.log('Error during acceptAll: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<SdkConsentStatus> querySDKConsentStatus(String sDKId) async {
    try {
      var status = await _channel
          .invokeMethod<int>('querySDKConsentStatus', <String, dynamic>{
        'sDKId': sDKId,
      });
      switch (status) {
        case 1:
          return SdkConsentStatus.given;
        case 0:
          return SdkConsentStatus.notGiven;
        default:
          return SdkConsentStatus.notBeenCollected;
      }
    } on PlatformException catch (e) {
      developer.log(
          'Error during querySDKConsentStatus: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<OTSdkData> get oTSDKData async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return OTSdkData(data);
    } on PlatformException catch (e) {
      developer.log('Error during get oTSDKData: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<BannerInfo> get banner async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return OTSdkData(data).banner;
    } on PlatformException catch (e) {
      developer.log('Error during get banner: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<PreferencesInfo> get preferenes async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return OTSdkData(data).preferences;
    } on PlatformException catch (e) {
      developer.log('Error during get preferences: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<List<Sdk>> get sdks async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return OTSdkData(data)
          .preferences
          .groups
          .expand((group) => group.sdks)
          .toList();
    } on PlatformException catch (e) {
      developer.log('Error during get sdks: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<bool> get shouldShowBanner async {
    try {
      return _channel.invokeMethod<bool>('shouldShowBanner');
    } on PlatformException catch (e) {
      developer.log(
          'Error during get shouldShowBanner: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }
}
