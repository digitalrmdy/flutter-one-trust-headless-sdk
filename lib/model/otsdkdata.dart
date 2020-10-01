import 'dart:convert';

import 'package:flutter/material.dart';

class OTSDKData {
  final String _data;
  Banner _banner;

  OTSDKData(this._data) {
    _banner = parseBanner();
  }

  String get data => _data;
  Banner get banner => _banner;

  Banner parseBanner() {
    var json = jsonDecode(_data);
    var domainData = json["culture"]["DomainData"];
    return Banner(
        showBanner: domainData["ShowAlertNotice"],
        message: domainData["AlertNoticeText"],
        allowAllButtonText: domainData["AlertAllowCookiesText"],
        moreInfoButtonText: domainData["AlertMoreInfoText"]);
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
