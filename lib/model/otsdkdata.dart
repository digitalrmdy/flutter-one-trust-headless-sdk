import 'dart:convert';

import 'package:flutter/material.dart';

class OTSDKData {
  final statusAlwaysActive = "always active";
  final statusActive = "active";

  final String _data;
  Banner _banner;
  Preferences _preferences;

  OTSDKData(this._data) {
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
        showBanner: domainData["ShowAlertNotice"],
        message: domainData["AlertNoticeText"],
        allowAllButtonText: domainData["AlertAllowCookiesText"],
        moreInfoButtonText: domainData["AlertMoreInfoText"]);
  }

  Preferences parsePreferences() {
    var json = jsonDecode(_data);
    var domainData = json["culture"]["DomainData"];
    List<SdkGroup> groups = (domainData["Groups"] as List)
        .where((g) => (g["FirstPartyCookies"] as List).isNotEmpty)
        .map((g) => SdkGroup(
              name: g["GroupName"],
              description: g["GroupDescription"],
              consentGiven: g["Status"] == statusAlwaysActive ||
                  g["Status"] == statusActive,
              editable: g["Status"] != statusAlwaysActive,
            ))
        .toList();

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
  final bool showBanner;
  final String message;
  final String allowAllButtonText;
  final String moreInfoButtonText;

  Banner(
      {@required this.showBanner,
      @required this.message,
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

  SdkGroup(
      {@required this.name,
      @required this.description,
      @required this.consentGiven,
      @required this.editable});
}
