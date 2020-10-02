import 'dart:convert';

import 'package:flutter/material.dart';

class OTSdkData {
  static const statusAlwaysActive = "always active";
  static const statusActive = "active";

  final String _data;
  BannerInfo _banner;
  PreferencesInfo _preferences;

  OTSdkData(this._data) {
    _banner = parseBanner();
    _preferences = parsePreferences();
  }

  String get data => _data;
  BannerInfo get banner => _banner;
  PreferencesInfo get preferences => _preferences;

  BannerInfo parseBanner() {
    var json = jsonDecode(_data);
    var domainData = json["culture"]["DomainData"];
    return BannerInfo(
        message: domainData["AlertNoticeText"],
        allowAllButtonText: domainData["AlertAllowCookiesText"],
        moreInfoButtonText: domainData["AlertMoreInfoText"]);
  }

  PreferencesInfo parsePreferences() {
    var json = jsonDecode(_data);
    var domainData = json["culture"]["DomainData"];
    List<SdkGroup> groups = (domainData["Groups"] as List)
        .where((g) => (g["FirstPartyCookies"] as List).isNotEmpty)
        .map(
      (g) {
        List<Sdk> sdks = (g["FirstPartyCookies"] as List).map(
          (s) {
            return Sdk(
              name: s["Name"],
              sdkId: s["SdkId"],
            );
          },
        ).toList();

        return SdkGroup(
          customId: g["CustomGroupId"],
          name: g["GroupName"],
          description: g["GroupDescription"],
          consentGiven:
              g["Status"] == statusAlwaysActive || g["Status"] == statusActive,
          editable: g["Status"] != statusAlwaysActive,
          statusLabel: _getStatusLabel(g["Status"]),
          sdks: sdks,
        );
      },
    ).toList();

    return PreferencesInfo(
        title: domainData["MainText"],
        message: domainData["MainInfoText"],
        acceptAllButtonText: domainData["ConfirmText"],
        saveChoicesButtonText: domainData["PreferenceCenterConfirmText"],
        cookiePreferencesTitle:
            domainData["PreferenceCenterManagePreferencesText"],
        groups: groups);
  }

  String _getStatusLabel(status) {
    var json = jsonDecode(_data);
    var domainData = json["culture"]["DomainData"];
    switch (status) {
      case statusAlwaysActive:
        return domainData["AlwaysActiveText"];
      case statusActive:
        return domainData["ActiveText"];
      default:
        return "";
    }
  }
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

  Sdk({@required this.name, @required this.sdkId});
}

enum SdkConsentStatus { given, notGiven, notBeenCollected }
