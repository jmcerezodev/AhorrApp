import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupMockPlatform() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Device Info - Blindaje Radical
  const MethodChannel deviceChannel = MethodChannel('dev.fluttercommunity.plus/device_info');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(deviceChannel, (MethodCall methodCall) async {
    return <String, dynamic>{
      'identifierForVendor': 'test-device-id',
      'brand': 'apple',
      'model': 'iphone',
      'androidId': 'test-android-id',
      'systemName': 'iOS',
      'systemVersion': '17.0',
      'name': 'iPhone',
      'localizedModel': 'iPhone',
      'utsname': {
        'sysname': 'Darwin',
        'nodename': 'iPhone',
        'release': '23.0.0',
        'version': 'Darwin Kernel Version 23.0.0',
        'machine': 'iPhone15,3',
      }
    };
  });

  // Mock Path Provider
  const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
    return '.';
  });

  // Mock Package Info
  const MethodChannel packageInfoChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(packageInfoChannel, (MethodCall methodCall) async {
    return {
      'appName': 'AhorrApp',
      'packageName': 'com.jmcerezo.ahorrapp',
      'version': '1.0.0',
      'buildNumber': '1',
    };
  });
}
