import 'dart:convert';

import 'package:flutter/material.dart';

class OTSdkData {
  static const statusAlwaysActive = "always active";
  static const statusActive = "active";

  String data;
  BannerInfo banner;
  PreferencesInfo preferences;

  OTSdkData(this.banner, this.preferences, this.data);
}

class BannerInfo {
  final String message;
  final String allowAllButtonText;
  final String moreInfoButtonText;

  BannerInfo(
      {@required this.message,
      @required this.allowAllButtonText,
      @required this.moreInfoButtonText});
}

class PreferencesInfo {
  final String title;
  final String message;
  final String acceptAllButtonText;
  final String saveChoicesButtonText;
  final String cookiePreferencesTitle;
  final List<SdkGroup> groups;

  PreferencesInfo(
      {@required this.title,
      @required this.message,
      @required this.acceptAllButtonText,
      @required this.cookiePreferencesTitle,
      @required this.saveChoicesButtonText,
      @required this.groups});
}

class SdkGroup {
  final String customId;
  final String name;
  final String description;
  final bool consentGiven;
  final bool editable;
  final String statusLabel;
  final List<Sdk> sdks;

  SdkGroup(
      {@required this.customId,
      @required this.name,
      @required this.description,
      @required this.consentGiven,
      @required this.editable,
      @required this.statusLabel,
      @required this.sdks});
}

class Sdk {
  final String name;
  final String sdkId;
  final SdkConsentStatus consentStatus;

  Sdk(
      {@required this.name,
      @required this.sdkId,
      @required this.consentStatus});
}

enum SdkConsentStatus { given, notGiven, notBeenCollected }

BannerInfo parseBanner(_data) {
  var json = jsonDecode(_data);
  var domainData = json["culture"]["DomainData"];
  return BannerInfo(
      message: domainData["AlertNoticeText"],
      allowAllButtonText: domainData["AlertAllowCookiesText"],
      moreInfoButtonText: domainData["AlertMoreInfoText"]);
}

Future<PreferencesInfo> parsePreferences(
    _data,
    Future<bool> Function(String customGroupId)
        querySDKConsentStatusForCategory,
    Future<SdkConsentStatus> Function(String sdkId)
        querySDKConsentStatus) async {
  var json = jsonDecode(_data);
  var domainData = json["culture"]["DomainData"];
  List<SdkGroup> groups = await Future.wait((domainData["Groups"] as List)
      .where((g) => (g["FirstPartyCookies"] as List).isNotEmpty)
      .map(
    (g) async {
      List<Sdk> sdks = await Future.wait((g["FirstPartyCookies"] as List).map(
        (s) async {
          var sdkId = s["SdkId"];
          var status = await querySDKConsentStatus(sdkId);
          return Sdk(name: s["Name"], sdkId: sdkId, consentStatus: status);
        },
      ).toList());

      var customGroupId = g["CustomGroupId"];
      var groupConsentStatus =
          await querySDKConsentStatusForCategory(customGroupId);

      return SdkGroup(
        customId: customGroupId,
        name: g["GroupName"],
        description: g["GroupDescription"],
        consentGiven: groupConsentStatus,
        editable: g["Status"] != OTSdkData.statusAlwaysActive,
        statusLabel: getStatusLabel(g["Status"], _data),
        sdks: sdks,
      );
    },
  ).toList());

  return PreferencesInfo(
      title: domainData["MainText"],
      message: domainData["MainInfoText"],
      acceptAllButtonText: domainData["ConfirmText"],
      saveChoicesButtonText: domainData["PreferenceCenterConfirmText"],
      cookiePreferencesTitle:
          domainData["PreferenceCenterManagePreferencesText"],
      groups: groups);
}

String getStatusLabel(status, _data) {
  var json = jsonDecode(_data);
  var domainData = json["culture"]["DomainData"];
  switch (status) {
    case OTSdkData.statusAlwaysActive:
      return domainData["AlwaysActiveText"];
    case OTSdkData.statusActive:
      return domainData["ActiveText"];
    default:
      return "";
  }
}
