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
  OTSDKData _data;
  bool _shouldShowBanner;
  bool _isLoading = true;

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
    OTSDKData data;
    String error;
    bool shouldShowBanner;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await OneTrustHeadlessSdk.init(
          storageLocation: "cdn.cookielaw.org",
          domainIdentifier: "f1383ce9-d3ad-4e0d-98bf-6e736846266b-test",
          languageCode: "en");
      shouldShowBanner = await OneTrustHeadlessSdk.shouldShowBanner;
      data = await OneTrustHeadlessSdk.oTSDKData;
    } on PlatformException catch (e) {
      error = "${e.code} - ${e.message}";
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = error;
      _data = data;
      _shouldShowBanner = shouldShowBanner;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                      : ConsentInformationScreen(_data, _shouldShowBanner),
                )
              : Text("loading..."),
        ),
      ),
    );
  }
}

class ConsentInformationScreen extends StatelessWidget {
  final OTSDKData data;
  final bool shouldShowBanner;

  ConsentInformationScreen(this.data, this.shouldShowBanner);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: Colors.grey,
          height: 32,
          child: Center(
            child: Text("BANNER"),
          ),
        ),
        Text(data.banner.message),
        MaterialButton(
          onPressed: () {
            OneTrustHeadlessSdk.acceptAll();
          },
          child: Text(data.banner.allowAllButtonText),
        ),
        Text("more info button:  ${data.banner.moreInfoButtonText}"),
        Text("show banner? $shouldShowBanner"),
        Container(
          color: Colors.grey,
          height: 32,
          child: Center(
            child: Text("PREFERENCES"),
          ),
        ),
        Text(data.preferences.title),
        Text(data.preferences.message),
        Text("accept all button:  ${data.preferences.acceptAllButtonText}"),
        Text(data.preferences.cookiePreferencesTitle),
        Text("save choices button:  ${data.preferences.saveChoicesButtonText}"),
        Container(
          color: Colors.grey,
          height: 32,
          child: Center(
            child: Text("SDK GROUPS"),
          ),
        ),
        ...data.preferences.groups.map(
          (g) => Column(
            children: [
              Text(g.name),
              Text(g.description),
              Text("consent given?  ${g.consentGiven}"),
              Text("editable?  ${g.editable}"),
              Container(
                color: Colors.grey,
                height: 8,
              )
            ],
          ),
        )
      ],
    );
  }
}
