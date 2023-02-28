import 'package:flutter/services.dart';
import 'package:zcar/platform/launcher.dart';

class ZCar {
  static final methodChannel = MethodChannel('zcar');

  static Future<List<AppInfo>> listAllApps() async {
    var result = await methodChannel.invokeListMethod('listAllApps');
    return result!.cast<Map>().map((e) => AppInfo.fromJson(e.cast<String, dynamic>())).toList();
  }

  static Future<void> runApp(String packageName) async {
    await methodChannel.invokeMethod('runApp', {
      'packageName': packageName
    });
  }
}