import 'dart:convert';

import 'package:flutter/material.dart';

class OTSdkData {
  final statusAlwaysActive = "always active";
  final statusActive = "active";

  final String _data;
  Banner _banner;
  Preferences _preferences;

  OTSdkData(this._data) {
    _banner = parseBanner();
    _preferences = parsePreferences();
  }

  String get data => _data;
  Banner get banner => _banner;
  Preferences get preferences => _preferences;

  Banner parseBanner() {
    var json = jsonDecode(_data);
    var domainData = json["culture"]["DomainData"];
    return Banner(
        message: domainData["AlertNoticeText"],
        allowAllButtonText: domainData["AlertAllowCookiesText"],
        moreInfoButtonText: domainData["AlertMoreInfoText"]);
  }

  Preferences parsePreferences() {
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
          name: g["GroupName"],
          description: g["GroupDescription"],
          consentGiven:
              g["Status"] == statusAlwaysActive || g["Status"] == statusActive,
          editable: g["Status"] != statusAlwaysActive,
          sdks: sdks,
        );
      },
    ).toList();

    return Preferences(
        title: domainData["MainText"],
        message: domainData["MainInfoText"],
        acceptAllButtonText: domainData["ConfirmText"],
        saveChoicesButtonText: domainData["PreferenceCenterConfirmText"],
        cookiePreferencesTitle:
            domainData["PreferenceCenterManagePreferencesText"],
        groups: groups);
  }
}

class Banner {
  final String message;
  final String allowAllButtonText;
  final String moreInfoButtonText;

  Banner(
      {@required this.message,
      @required this.allowAllButtonText,
      @required this.moreInfoButtonText});
}

class Preferences {
  final String title;
  final String message;
  final String acceptAllButtonText;
  final String saveChoicesButtonText;
  final String cookiePreferencesTitle;
  final List<SdkGroup> groups;

  Preferences(
      {@required this.title,
      @required this.message,
      @required this.acceptAllButtonText,
      @required this.cookiePreferencesTitle,
      @required this.saveChoicesButtonText,
      @required this.groups});
}

class SdkGroup {
  final String name;
  final String description;
  final bool consentGiven;
  final bool editable;
  final List<Sdk> sdks;

  SdkGroup(
      {@required this.name,
      @required this.description,
      @required this.consentGiven,
      @required this.editable,
      @required this.sdks});
}

class Sdk {
  final String name;
  final String sdkId;

  Sdk({@required this.name, @required this.sdkId});
}

enum SdkConsentStatus { given, notGiven, notBeenCollected }
