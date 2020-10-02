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
    OTSdkData data;
    String error;
    bool shouldShowBanner;
    Map<String, SdkConsentStatus> consentStatus = {};
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await OneTrustHeadlessSdk.init(
          storageLocation: "cdn.cookielaw.org",
          domainIdentifier: "f1383ce9-d3ad-4e0d-98bf-6e736846266b-test",
          languageCode: "en");
      shouldShowBanner = await OneTrustHeadlessSdk.shouldShowBanner;
      data = await OneTrustHeadlessSdk.oTSDKData;
      for (var group in data.preferences.groups) {
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
                      : ConsentInformationScreen(
                          _data, _shouldShowBanner, _consentStatus),
                )
              : Text("loading..."),
        ),
      ),
    );
  }
}

class ConsentInformationScreen extends StatelessWidget {
  final OTSdkData data;
  final bool shouldShowBanner;
  final Map<String, SdkConsentStatus> _consentStatus;

  ConsentInformationScreen(
      this.data, this.shouldShowBanner, this._consentStatus);

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
              Text(data.banner.message),
              MaterialButton(
                color: Colors.green,
                onPressed: () {
                  OneTrustHeadlessSdk.acceptAll();
                },
                child: Text(data.banner.allowAllButtonText),
              ),
              Text("more info button:  ${data.banner.moreInfoButtonText}"),
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
              Text(data.preferences.title),
              Text(data.preferences.message),
              Text(
                  "accept all button:  ${data.preferences.acceptAllButtonText}"),
              Text(data.preferences.cookiePreferencesTitle),
              Text(
                  "save choices button:  ${data.preferences.saveChoicesButtonText}"),
              Container(
                height: 32,
                child: Center(
                  child: Text(
                    "SDK Groups",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...data.preferences.groups.map(
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
                      Text("consent given?  ${g.consentGiven}"),
                      SizedBox(
                        height: 8,
                      ),
                      Text("editable?  ${g.editable}"),
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
