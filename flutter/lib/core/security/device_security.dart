import 'dart:io';
import 'package:flutter/foundation.dart';

class DeviceSecurity {
  DeviceSecurity._();

  static Future<bool> isDeviceCompromised() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isAndroid) {
        return await _isAndroidRooted();
      } else if (Platform.isIOS) {
        return await _isiOSJailbroken();
      }
    } catch (_) {}

    return false;
  }

  static Future<bool> _isAndroidRooted() async {
    final rootPaths = [
      '/system/app/Superuser.apk',
      '/sbin/su',
      '/system/bin/su',
      '/system/xbin/su',
      '/data/local/xbin/su',
      '/data/local/bin/su',
      '/system/sd/xbin/su',
      '/system/bin/failsafe/su',
      '/data/local/su',
      '/su/bin/su',
    ];

    for (final path in rootPaths) {
      try {
        if (await File(path).exists()) return true;
      } catch (_) {}
    }

    try {
      final result = await Process.run('which', ['su']);
      if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  static Future<bool> _isiOSJailbroken() async {
    final jailbreakPaths = [
      '/Applications/Cydia.app',
      '/Library/MobileSubstrate/MobileSubstrate.dylib',
      '/bin/bash',
      '/usr/sbin/sshd',
      '/etc/apt',
      '/private/var/lib/apt',
    ];

    for (final path in jailbreakPaths) {
      try {
        if (await File(path).exists()) return true;
      } catch (_) {}
    }

    try {
      final result = await Process.run('id', []);
      if (result.stdout.toString().contains('root')) return true;
    } catch (_) {}

    return false;
  }

  static bool isDebugMode() {
    var debug = false;
    assert(debug = true);
    return debug;
  }

  static bool isRunningOnEmulator() {
    try {
      if (Platform.isAndroid) {
        final fingerprints = [
          'google/sdk_gphone',
          'generic',
          'emu64',
          'android-emulator',
        ];
        final properties = <String>[];
        try {
          final result = File('/system/build.prop').readAsStringSync();
          properties.addAll(result.split('\n'));
        } catch (_) {}

        for (final prop in properties) {
          for (final fingerprint in fingerprints) {
            if (prop.toLowerCase().contains(fingerprint)) {
              return true;
            }
          }
        }
      }
    } catch (_) {}

    return false;
  }
}
