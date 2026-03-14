import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupAllMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock Device Info - Blindaje Maestro
  const List<String> deviceChannels = [
    'dev.fluttercommunity.plus/device_info',
    'plugins.flutter.io/device_info',
  ];

  for (final channelName in deviceChannels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(channelName), (MethodCall methodCall) async {
      return <String, dynamic>{
        'identifierForVendor': 'test-id',
        'brand': 'apple',
        'model': 'iphone',
        'androidId': 'test-id',
        'systemName': 'iOS',
        'systemVersion': '15.0',
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
  }

  // Mock Package Info
  const List<String> packageChannels = [
    'dev.fluttercommunity.plus/package_info',
    'plugins.flutter.io/package_info',
  ];

  for (final channelName in packageChannels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(channelName), (MethodCall methodCall) async {
      return {
        'appName': 'AhorrApp',
        'packageName': 'com.jmcerezo.ahorrapp',
        'version': '1.0.0',
        'buildNumber': '1',
      };
    });
  }

  // Mock Path Provider
  const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
    return '.';
  });
}

// Alias para compatibilidad con llamadas anteriores
void setupMockPlatform() => setupAllMocks();
