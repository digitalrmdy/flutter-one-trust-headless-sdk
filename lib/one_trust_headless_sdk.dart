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

  static Map<String, Function(String, SdkConsentStatus)> _listeners = {};

  static Future<void> init(
      {@required String storageLocation,
      @required String domainIdentifier,
      @required String languageCode,
      @required String countryCode,
      String regionCode}) async {
    try {
      await _channel.invokeMethod<bool>('init', <String, dynamic>{
        'storageLocation': storageLocation,
        'domainIdentifier': domainIdentifier,
        'languageCode': languageCode,
        'countryCode': countryCode,
        if (regionCode != null) 'regionCode': regionCode,
      });
    } on PlatformException catch (e) {
      developer.log('Error during init: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
    _registerMethodCallHandler();
  }

  static void _registerMethodCallHandler() {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "sdkConsentStatusUpdated":
          {
            var listener = _listeners[call.arguments["sdkId"]];
            if (listener != null) {
              listener(call.arguments["sdkId"],
                  _mapSdkConsentStatus(call.arguments["consentStatus"]));
            }
          }
          break;
        default:
          break;
      }
      return;
    });
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

  static Future<SdkConsentStatus> queryConsentStatusForSdk(String sdkId) async {
    try {
      var status = await _channel
          .invokeMethod<int>('queryConsentStatusForSdk', <String, dynamic>{
        'sdkId': sdkId,
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
          'Error during queryConsentStatusForSdk: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<OTSdkData> get oTSDKData async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return _parseData(data, queryConsentStatusForCategory);
    } on PlatformException catch (e) {
      developer.log('Error during get oTSDKData: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<BannerInfo> get banner async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return (await _parseData(data, queryConsentStatusForCategory)).banner;
    } on PlatformException catch (e) {
      developer.log('Error during get banner: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<PreferencesInfo> get preferences async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return (await _parseData(data, queryConsentStatusForCategory))
          .preferences;
    } on PlatformException catch (e) {
      developer.log('Error during get preferences: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<List<Sdk>> get sdks async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return (await _parseData(data, queryConsentStatusForCategory))
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

  static Future<void> updateSdkGroupConsent(
      String customGroupId, bool consentGiven) async {
    try {
      await _channel
          .invokeMethod<bool>('updateSdkGroupConsent', <String, dynamic>{
        'customGroupId': customGroupId,
        'consentGiven': consentGiven,
      });
    } on PlatformException catch (e) {
      developer.log(
          'Error during updateSdkGroupConsent: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<void> confirmConsentChanges() async {
    try {
      await _channel.invokeMethod<bool>('confirmConsentChanges');
    } on PlatformException catch (e) {
      developer.log(
          'Error during confirmConsentChanges: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<void> resetConsentChanges() async {
    try {
      await _channel.invokeMethod<bool>('resetConsentChanges');
    } on PlatformException catch (e) {
      developer.log(
          'Error during resetConsentChanges: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<void> registerSdkListener(
      {@required
          String sdkId,
      @required
          Function(String, SdkConsentStatus) onSdkConsentStatusChanged}) async {
    try {
      await _channel
          .invokeMethod<bool>('registerSdkListener', <String, dynamic>{
        'sdkId': sdkId,
      });
      _listeners[sdkId] = onSdkConsentStatusChanged;
    } on PlatformException catch (e) {
      developer.log(
          'Error during registerSdkListener: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<void> clearSdkListeners() async {
    try {
      await _channel.invokeMethod<bool>('clearSdkListeners');
      _listeners.clear();
    } on PlatformException catch (e) {
      developer.log('Error during clearSdkListeners: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<bool> queryConsentStatusForCategory(
      String customGroupId) async {
    try {
      var status = await _channel
          .invokeMethod<int>('queryConsentStatusForCategory', <String, dynamic>{
        'customGroupId': customGroupId,
      });
      switch (status) {
        case 1:
          return true;
        default:
          return false;
      }
    } on PlatformException catch (e) {
      developer.log(
          'Error during queryConsentStatusForCategory: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<OTSdkData> _parseData(
      String data,
      Future<bool> Function(String customGroupId)
          querySDKConsentStatusForCategory) async {
    var banner = parseBanner(data);
    var preferences = await parsePreferences(
        data, queryConsentStatusForCategory, queryConsentStatusForSdk);
    return OTSdkData(banner, preferences, data);
  }

  static SdkConsentStatus _mapSdkConsentStatus(int status) {
    switch (status) {
      case 1:
        return SdkConsentStatus.given;
      case 0:
        return SdkConsentStatus.notGiven;
      default:
        return SdkConsentStatus.notBeenCollected;
    }
  }
}
