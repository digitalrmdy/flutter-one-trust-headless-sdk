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
  OTSDKData _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    OTSDKData data;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      data = await OneTrustHeadlessSdk.oTSDKData;
      _isLoading = false;
    } on PlatformException {
      _isLoading = false;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: !_isLoading
              ? Text(
                  'data: ${_data != null ? _data.data : "something went wrong"}')
              : Text("loading..."),
        ),
      ),
    );
  }
}
