import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:one_trust_headless_sdk/one_trust_headless_sdk.dart';
import 'package:one_trust_headless_sdk/model/otsdkdata.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _error;
  OTSdkData _data;
  BannerInfo _banner;
  PreferencesInfo _preferences;
  bool _shouldShowBanner;
  bool _isLoading = true;
  Map<String, SdkConsentStatus> _consentStatus;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    setState(() {
      _isLoading = true;
    });
    String error;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await OneTrustHeadlessSdk.init(
          storageLocation: "cdn.cookielaw.org",
          domainIdentifier: "f1383ce9-d3ad-4e0d-98bf-6e736846266b-test",
          languageCode: "en");
    } on PlatformException catch (e) {
      error = "${e.code} - ${e.message}";
    }
    await _updateData();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = error;
    });
  }

  _updateData() async {
    setState(() {
      _isLoading = true;
    });
    String error;
    OTSdkData data;
    bool shouldShowBanner;
    BannerInfo banner;
    PreferencesInfo preferences;
    List<Sdk> sdks;
    Map<String, SdkConsentStatus> consentStatus = {};
    try {
      data = await OneTrustHeadlessSdk.oTSDKData;
      shouldShowBanner = await OneTrustHeadlessSdk.shouldShowBanner;
      banner = await OneTrustHeadlessSdk.banner;
      preferences = await OneTrustHeadlessSdk.preferenes;
      sdks = await OneTrustHeadlessSdk.sdks;
      for (var group in preferences.groups) {
        for (var sdk in group.sdks) {
          var status =
              await OneTrustHeadlessSdk.querySDKConsentStatus(sdk.sdkId);
          consentStatus[sdk.sdkId] = status;
        }
      }
    } on PlatformException catch (e) {
      error = "${e.code} - ${e.message}";
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = error;
      _data = data;
      _banner = banner;
      _preferences = preferences;
      _shouldShowBanner = shouldShowBanner;
      _consentStatus = consentStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('One Trust Headless SDK'),
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _data.data));
                  },
                  child: Icon(
                    Icons.content_copy,
                    size: 26.0,
                  ),
                )),
          ],
        ),
        body: Center(
          child: !_isLoading
              ? Container(
                  child: _error != null
                      ? Text("Error $_error")
                      : ConsentInformationScreen(_banner, _preferences,
                          _shouldShowBanner, _consentStatus, _updateData),
                )
              : Text("loading..."),
        ),
      ),
    );
  }
}

class ConsentInformationScreen extends StatelessWidget {
  final BannerInfo banner;
  final PreferencesInfo preferences;
  final bool shouldShowBanner;
  final Map<String, SdkConsentStatus> _consentStatus;
  final Function update;

  ConsentInformationScreen(this.banner, this.preferences, this.shouldShowBanner,
      this._consentStatus, this.update);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: Colors.grey,
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 32,
                child: Center(
                  child: Text(
                    "Banner",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Text(banner.message),
              MaterialButton(
                color: Colors.green,
                onPressed: () async {
                  OneTrustHeadlessSdk.acceptAll();
                  await update();
                },
                child: Text(banner.allowAllButtonText),
              ),
              Text("more info button:  ${banner.moreInfoButtonText}"),
              Text("show banner? $shouldShowBanner"),
            ],
          ),
        ),
        Container(
          color: Colors.grey,
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 32,
                child: Center(
                  child: Text(
                    "Preferences",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Text(preferences.title),
              Text(preferences.message),
              Text("accept all button:  ${preferences.acceptAllButtonText}"),
              Text(preferences.cookiePreferencesTitle),
              Text(
                  "save choices button:  ${preferences.saveChoicesButtonText}"),
              Container(
                height: 32,
                child: Center(
                  child: Text(
                    "SDK Groups",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...preferences.groups.map(
                (g) => Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(16),
                  color: Colors.blueGrey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(g.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Text(g.description),
                      SizedBox(
                        height: 8,
                      ),
                      Text(g.customId),
                      SizedBox(
                        height: 8,
                      ),
                      if (g.editable)
                        MaterialButton(
                          onPressed: () async {
                            await OneTrustHeadlessSdk.updateSdkGroupConsent(
                                g.customId, !g.consentGiven);
                            await OneTrustHeadlessSdk.confirmConsentChanges();
                            await update();
                          },
                          color: Colors.blue,
                          child: Text(g.consentGiven
                              ? "disable consent"
                              : "enable consent"),
                        )
                      else
                        Text("${g.statusLabel}"),
                      Container(
                        height: 48,
                        child: Center(
                          child: Text(
                            "included SDKs",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ...g.sdks.map(
                        (s) {
                          return Container(
                            margin: EdgeInsets.all(8),
                            padding: EdgeInsets.all(16),
                            color: Colors.blue,
                            child: Column(
                              children: [
                                Text(s.name),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(s.sdkId),
                                SizedBox(
                                  height: 8,
                                ),
                                Text("consent? ${_consentStatus[s.sdkId]}"),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
