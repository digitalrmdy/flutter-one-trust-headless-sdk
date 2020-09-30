import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_trust_headless_sdk/one_trust_headless_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('one_trust_headless_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await OneTrustHeadlessSdk.platformVersion, '42');
  });
}
