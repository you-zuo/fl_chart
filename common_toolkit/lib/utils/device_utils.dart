import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceUtils {
  static String? _deviceId;

  // 获取设备信息
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const AndroidId _androidIdPlugin = AndroidId();

  static FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  static String _deviceIDKey = 'deviceId';

  ///第一次安装
  static bool isFirstInstall = true;
  static String packageName = '';
  static int platformCode = Platform.isIOS ? 1 : 2;

  ///初始化
  static Future<void> init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    packageName = packageInfo.packageName;
    _deviceIDKey = '${packageName}_$_deviceIDKey';
    isFirstInstall = !(await secureStorage.containsKey(key: _deviceIDKey));
    print('isFirstInstall: $isFirstInstall');
    await getDeviceId();
  }

  ///清除设备ID
  static Future<void> clearDeviceId() async {
    await secureStorage.delete(key: _deviceIDKey);
    isFirstInstall = true;
    _deviceId = null;
  }

  /// 获取唯一设备 ID
  static Future<String> getDeviceId() async {
    // 如果已经获取过设备ID，则直接返回
    if (_deviceId != null && _deviceId!.isNotEmpty) {
      return _deviceId!;
    }
    try {
      // 从本地获取设备ID
      String? deviceId;
      if (await secureStorage.containsKey(key: _deviceIDKey)) {
        deviceId = await secureStorage.read(key: _deviceIDKey);
      }

      if (deviceId != null && deviceId.isNotEmpty) {
        _deviceId = deviceId;
        return _deviceId!;
      }

      if (kIsWeb) {
        _deviceId = '';
      } else {
        _deviceId = switch (defaultTargetPlatform) {
          TargetPlatform.android => await _getAndroidDeviceId(),
          TargetPlatform.iOS => await _getIOSDeviceId(),
          TargetPlatform.linux => '',
          TargetPlatform.windows => '',
          TargetPlatform.macOS => '',
          TargetPlatform.fuchsia => '',
        };
      }
    } catch (e) {}
    if (_deviceId == null || _deviceId!.isEmpty) {
      _deviceId = const Uuid().v4();
    }
    secureStorage.write(key: _deviceIDKey, value: _deviceId);

    return _deviceId!;
  }

  ///重置设备ID
  static Future<void> resetDeviceId() async {
    _deviceId = const Uuid().v4();
    await secureStorage.write(key: _deviceIDKey, value: _deviceId);
  }

  /// 获取iOS设备ID
  static Future<String> _getIOSDeviceId() async {
    final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
    final String? iosId = iosInfo.identifierForVendor;

    if (iosId != null && iosId.isNotEmpty) {
      return iosId;
    }
    return const Uuid().v4();
  }

  /// 获取安卓设备ID
  static Future<String> _getAndroidDeviceId() async {
    final String? androidId = await _androidIdPlugin.getId();

    // 用 9774d56d682e549c 作为 androidId 时，返回空字符串
    // 根据 AndroidId 生成 UUID
    if (androidId != null &&
        androidId.isNotEmpty &&
        androidId != '9774d56d682e549c') {
      return androidId;
    }
    return const Uuid().v4();
  }
}
