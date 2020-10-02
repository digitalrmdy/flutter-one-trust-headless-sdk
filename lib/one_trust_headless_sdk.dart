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
      {@required
          String storageLocation,
      @required
          String domainIdentifier,
      @required
          String languageCode,
      @required
          Function(String, SdkConsentStatus) onSdkConsentStatusChanged}) async {
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
    _registerMethodCallHandler(onSdkConsentStatusChanged);
  }

  static void _registerMethodCallHandler(
      onSdkConsentStatusChanged(
          String sdkId, SdkConsentStatus sdkConsentStatus)) {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "sdkConsentStatusUpdated":
          onSdkConsentStatusChanged(call.arguments["sdkId"],
              _mapSdkConsentStatus(call.arguments["consentStatus"]));
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

  static Future<SdkConsentStatus> querySDKConsentStatus(String sdkId) async {
    try {
      var status = await _channel
          .invokeMethod<int>('querySDKConsentStatus', <String, dynamic>{
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
          'Error during querySDKConsentStatus: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<OTSdkData> get oTSDKData async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return _parseData(data, querySDKConsentStatusForCategory);
    } on PlatformException catch (e) {
      developer.log('Error during get oTSDKData: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<BannerInfo> get banner async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return (await _parseData(data, querySDKConsentStatusForCategory)).banner;
    } on PlatformException catch (e) {
      developer.log('Error during get banner: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<PreferencesInfo> get preferences async {
    try {
      final String data = await _channel.invokeMethod<String>('getOTSDKData');
      return (await _parseData(data, querySDKConsentStatusForCategory))
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
      return (await _parseData(data, querySDKConsentStatusForCategory))
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
    debugPrint("updating consent for $customGroupId to $consentGiven");
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

  static Future<void> registerSdkListener(String sdkId) async {
    try {
      await _channel
          .invokeMethod<bool>('registerSdkListener', <String, dynamic>{
        'sdkId': sdkId,
      });
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
    } on PlatformException catch (e) {
      developer.log('Error during clearSdkListeners: ${e.code} - ${e.message}',
          name: 'one_trust_headless_sdk');
      rethrow;
    }
  }

  static Future<bool> querySDKConsentStatusForCategory(
      String customGroupId) async {
    try {
      var status = await _channel.invokeMethod<int>(
          'querySDKConsentStatusForCategory', <String, dynamic>{
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
          'Error during querySDKConsentStatusForCategory: ${e.code} - ${e.message}',
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
        data, querySDKConsentStatusForCategory, querySDKConsentStatus);
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
